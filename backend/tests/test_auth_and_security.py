import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.core.database import Base, get_db
from app.models.user import User, UserRole
from app.core.security import get_password_hash

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
async def test_register_user_us_007():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "email": "gardener@urbanplants.vn",
            "password": "SecretPassword123",
            "full_name": "Nguyễn Văn Làm Vườn",
            "location_city": "TP. Hồ Chí Minh"
        }
        res = await ac.post("/api/v1/auth/register", json=payload)
        assert res.status_code == 201
        data = res.json()
        assert "access_token" in data
        assert data["user"]["email"] == "gardener@urbanplants.vn"
        assert data["user"]["role"] == "USER"

@pytest.mark.asyncio
async def test_oauth_login_us_008():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "provider": "google",
            "id_token": "mock_google_id_token_12345",
            "email": "google.user@gmail.com",
            "full_name": "Google Urban User"
        }
        res = await ac.post("/api/v1/auth/oauth", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert "access_token" in data
        assert data["user"]["email"] == "google.user@gmail.com"

@pytest.mark.asyncio
async def test_forgot_password_and_reset_us_009():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # 1. Tạo tài khoản trước
        await ac.post("/api/v1/auth/register", json={
            "email": "forgot@urbanplants.vn",
            "password": "OldPassword123",
            "full_name": "User Forgot"
        })
        # 2. Gửi yêu cầu OTP
        res_forgot = await ac.post("/api/v1/auth/forgot-password", json={"email": "forgot@urbanplants.vn"})
        assert res_forgot.status_code == 200
        msg = res_forgot.json()["message"]
        # Lấy OTP demo từ message
        otp_code = msg.split("Demo OTP: ")[-1].replace(")", "").strip()

        # 3. Đặt lại mật khẩu
        res_reset = await ac.post("/api/v1/auth/reset-password", json={
            "email": "forgot@urbanplants.vn",
            "otp_code": otp_code,
            "new_password": "NewSecretPassword123"
        })
        assert res_reset.status_code == 200

        # 4. Đăng nhập lại với mật khẩu mới
        res_login = await ac.post("/api/v1/auth/login", json={
            "identifier": "forgot@urbanplants.vn",
            "password": "NewSecretPassword123"
        })
        assert res_login.status_code == 200

@pytest.mark.asyncio
async def test_update_profile_and_biometric_us_010_011():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        reg = await ac.post("/api/v1/auth/register", json={
            "email": "profile@urbanplants.vn",
            "password": "Password123",
            "full_name": "Original Name"
        })
        token = reg.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # US-010: Cập nhật thông tin cá nhân
        res_update = await ac.put("/api/v1/users/me", headers=headers, json={
            "full_name": "Updated Name Master",
            "location_city": "Hà Nội"
        })
        assert res_update.status_code == 200
        assert res_update.json()["full_name"] == "Updated Name Master"
        assert res_update.json()["location_city"] == "Hà Nội"

        # US-011: Bật sinh trắc học
        res_bio = await ac.post("/api/v1/auth/biometric/enable", headers=headers, json={
            "biometric_public_key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA"
        })
        assert res_bio.status_code == 200

@pytest.mark.asyncio
async def test_delete_account_us_013():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        reg = await ac.post("/api/v1/auth/register", json={
            "email": "delete.me@urbanplants.vn",
            "password": "Password123",
            "full_name": "To Be Deleted"
        })
        token = reg.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Xóa tài khoản vĩnh viễn chuẩn CH Play
        res_del = await ac.request("DELETE", "/api/v1/users/me", headers=headers, json={
            "confirm_text": "XOA TAI KHOAN",
            "password": "Password123"
        })
        assert res_del.status_code == 200

        # Kiểm tra token không còn dùng được
        res_check = await ac.get("/api/v1/users/me", headers=headers)
        assert res_check.status_code == 401
