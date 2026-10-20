import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.core.database import Base, get_db
from app.models.user import User, UserRole

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"
test_engine = create_async_engine(TEST_DATABASE_URL, echo=False)
TestingSessionLocal = async_sessionmaker(
    bind=test_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session

app.dependency_overrides[get_db] = override_get_db

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.mark.asyncio
async def test_plant_catalog_and_filter_us_016_017_018():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # Lấy danh mục cây trồng mặc định
        res = await ac.get("/api/v1/garden/catalog")
        assert res.status_code == 200
        data = res.json()
        assert len(data) >= 5 # Hoa hồng, Sen đá, Monstera, Cà chua bi, Ớt

        # Tìm kiếm theo tên "Hoa Hồng"
        res_search = await ac.get("/api/v1/garden/catalog?q=Hoa Hồng")
        assert res_search.status_code == 200
        assert any("Hoa Hồng" in item["common_name_vi"] for item in res_search.json())

        # Lọc theo ánh sáng "DIRECT_SUN"
        res_filter = await ac.get("/api/v1/garden/catalog?light=DIRECT_SUN")
        assert res_filter.status_code == 200
        for item in res_filter.json():
            assert item["light_requirement"] == "DIRECT_SUN"

@pytest.mark.asyncio
async def test_my_garden_and_plant_crud_us_019_to_025():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # 1. Đăng ký tài khoản
        reg = await ac.post("/api/v1/auth/register", json={
            "email": "gardener2@urbanplants.vn",
            "password": "Password123",
            "full_name": "Lê Làm Vườn"
        })
        token = reg.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. Tạo góc vườn (US-025)
        res_garden = await ac.post("/api/v1/garden/gardens", headers=headers, json={
            "garden_name": "Vườn Ban Công Hướng Đông",
            "location_tag": "Ban công Đông",
            "is_outdoor": True
        })
        assert res_garden.status_code == 201
        garden_id = res_garden.json()["id"]

        # 3. Thêm cây vào vườn (US-019, US-020, US-021)
        res_plant = await ac.post("/api/v1/garden/plants", headers=headers, json={
            "garden_id": garden_id,
            "custom_name": "Chậu Hồng Mon Coeur Mini",
            "location_tag": "Ban công hướng Đông",
            "pot_size_cm": 30,
            "custom_water_interval_days": 1
        })
        assert res_plant.status_code == 201
        plant_id = res_plant.json()["id"]

        # 4. Ghi chép nhật ký sinh trưởng (US-022)
        res_log = await ac.post("/api/v1/garden/growth-logs", headers=headers, json={
            "user_plant_id": plant_id,
            "height_cm": 35.5,
            "growth_milestone": "Đơm nụ đợt 1",
            "note": "Cây ra 3 nụ hoa rất khỏe sau khi bón phân trùn quế."
        })
        assert res_log.status_code == 201

        # 5. Xem lịch sử nhật ký sinh trưởng
        res_history = await ac.get(f"/api/v1/garden/plants/{plant_id}/growth-logs", headers=headers)
        assert res_history.status_code == 200
        assert len(res_history.json()) == 1

        # 6. Chỉnh sửa thông tin cây (US-023)
        res_update = await ac.put(f"/api/v1/garden/plants/{plant_id}", headers=headers, json={
            "custom_name": "Chậu Hồng Mon Coeur Đang Hoa",
            "pot_size_cm": 35
        })
        assert res_update.status_code == 200
        assert res_update.json()["custom_name"] == "Chậu Hồng Mon Coeur Đang Hoa"

        # 7. Xuất báo cáo cây (US-026)
        res_report = await ac.get(f"/api/v1/garden/plants/{plant_id}/report", headers=headers)
        assert res_report.status_code == 200
        assert "growth_timeline" in res_report.json()

        # 8. Đánh dấu đã tặng/chết (US-024)
        res_archive = await ac.post(f"/api/v1/garden/plants/{plant_id}/archive", headers=headers, json={
            "archive_reason": "GIFTED"
        })
        assert res_archive.status_code == 200
        assert res_archive.json()["is_active"] is False

@pytest.mark.asyncio
async def test_smart_schedule_weather_and_vacation_us_027_to_036():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        reg = await ac.post("/api/v1/auth/register", json={
            "email": "schedule.user@urbanplants.vn",
            "password": "Password123",
            "full_name": "Trần Lịch Trình"
        })
        token = reg.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Thêm cây đặt ngoài ban công để kiểm tra tự hoãn khi mưa (US-032)
        res_plant = await ac.post("/api/v1/garden/plants", headers=headers, json={
            "custom_name": "Cà Chua Bi Ngoài Ban Công",
            "location_tag": "Ban công ngoài trời",
            "pot_size_cm": 25
        })
        plant_id = res_plant.json()["id"]

        # US-027, US-032: Lấy lịch tưới tự động
        res_schedules = await ac.get("/api/v1/garden/schedules", headers=headers)
        assert res_schedules.status_code == 200
        schedules = res_schedules.json()
        assert len(schedules) >= 1
        schedule_item = schedules[0]
        # Do TP.HCM mặc định có mưa dông 80% và cây ngoài ban công -> weather_skip_flag = True
        assert schedule_item["weather_skip_flag"] is True

        # US-029: Thao tác nhanh Đã tưới
        res_act = await ac.post(
            f"/api/v1/garden/schedules/{schedule_item['id']}/action",
            headers=headers,
            json={"action": "COMPLETE"}
        )
        assert res_act.status_code == 200
        assert res_act.json()["is_completed"] is True

        # US-031, US-033, US-034: Kiểm tra thời tiết và cảnh báo sốc nhiệt
        res_weather = await ac.get("/api/v1/weather/current?city=TP. Hồ Chí Minh")
        assert res_weather.status_code == 200
        weather_data = res_weather.json()
        assert weather_data["temperature_celsius"] >= 38.0
        assert any(alert["alert_type"] == "HEAT_WAVE" for alert in weather_data["alerts"])

        # US-036: Bật chế độ đi vắng
        res_vacation = await ac.put("/api/v1/garden/vacation", headers=headers, json={
            "is_vacation_mode": True,
            "vacation_note": "Đi công tác Đà Nẵng 5 ngày"
        })
        assert res_vacation.status_code == 200
        assert res_vacation.json()["is_vacation_mode"] is True
