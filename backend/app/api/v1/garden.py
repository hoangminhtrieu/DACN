from typing import List, Optional
from datetime import date
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.deps import get_current_active_user
from app.models.user import User
from app.models.garden import LightRequirement, PlantDifficulty
from app.repositories.garden_repository import GardenRepository
from app.services.smart_schedule_service import SmartScheduleService
from app.services.weather_service import WeatherService
from app.schemas.garden import (
    PlantCatalogResponse,
    UserGardenCreate,
    UserGardenResponse,
    UserPlantCreate,
    UserPlantUpdate,
    UserPlantResponse,
    UserPlantArchiveRequest,
    GrowthLogCreate,
    GrowthLogResponse,
    CareScheduleResponse,
    ScheduleActionRequest,
    VacationModeRequest,
    VacationModeResponse
)

router = APIRouter(prefix="/garden", tags=["Garden & Smart Care Management"])

def get_garden_repo(db: AsyncSession = Depends(get_db)) -> GardenRepository:
    return GardenRepository(db)

def get_schedule_service(
    repo: GardenRepository = Depends(get_garden_repo)
) -> SmartScheduleService:
    weather_svc = WeatherService()
    return SmartScheduleService(repo, weather_svc)

# --- US-016, US-017, US-018: Danh mục Cây Đô Thị ---
@router.get("/catalog", response_model=List[PlantCatalogResponse])
async def get_plant_catalog(
    q: Optional[str] = Query(None, description="Tìm kiếm theo tên tiếng Việt hoặc tên khoa học"),
    light: Optional[LightRequirement] = Query(None, description="Lọc theo điều kiện ánh sáng"),
    difficulty: Optional[PlantDifficulty] = Query(None, description="Lọc theo độ khó chăm sóc"),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-016, US-017, US-018: Tra cứu danh mục cây cảnh đô thị, tìm kiếm và lọc thông minh"""
    await repo.seed_default_catalog_if_empty()
    return await repo.search_and_filter_catalog(query=q, light=light, difficulty=difficulty)

# --- US-019, US-025: Quản lý Vườn & Góc Vườn ---
@router.post("/gardens", response_model=UserGardenResponse, status_code=status.HTTP_201_CREATED)
async def create_user_garden(
    req: UserGardenCreate,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-025: Phân nhóm cây theo từng góc vườn (Ban công, Sân thượng, Phòng khách)"""
    from app.models.garden import UserGarden
    garden = UserGarden(user_id=current_user.id, **req.model_dump())
    return await repo.create_user_garden(garden)

@router.get("/gardens", response_model=List[UserGardenResponse])
async def list_user_gardens(
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    return await repo.get_user_gardens(current_user.id)

# --- US-019 .. US-024: Chậu Cây trong Vườn ---
@router.post("/plants", response_model=UserPlantResponse, status_code=status.HTTP_201_CREATED)
async def add_plant_to_garden(
    req: UserPlantCreate,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-019, US-020, US-021: Thêm cây mới vào 'Vườn của tôi', tải ảnh và gắn thẻ vị trí"""
    from app.models.garden import UserPlant
    plant_data = req.model_dump()
    if not plant_data.get("planted_date"):
        plant_data["planted_date"] = date.today()
    plant = UserPlant(user_id=current_user.id, **plant_data)
    return await repo.create_user_plant(plant)

@router.get("/plants", response_model=List[UserPlantResponse])
async def get_my_plants(
    active_only: bool = True,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    return await repo.get_user_plants(current_user.id, active_only=active_only)

@router.get("/plants/{plant_id}", response_model=UserPlantResponse)
async def get_plant_detail(
    plant_id: str,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    plant = await repo.get_user_plant_by_id(plant_id)
    return plant

@router.put("/plants/{plant_id}", response_model=UserPlantResponse)
async def update_plant_info(
    plant_id: str,
    req: UserPlantUpdate,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-023: Chỉnh sửa thông tin cây khi thay đổi vị trí hoặc kích thước chậu"""
    plant = await repo.get_user_plant_by_id(plant_id)
    update_data = req.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(plant, k, v)
    return await repo.update_user_plant(plant)

@router.post("/plants/{plant_id}/archive", response_model=UserPlantResponse)
async def archive_plant(
    plant_id: str,
    req: UserPlantArchiveRequest,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-024: Đánh dấu cây đã chết hoặc cho/tặng để cập nhật lại danh sách vườn thực tế"""
    plant = await repo.get_user_plant_by_id(plant_id)
    plant.is_active = False
    plant.archive_reason = req.archive_reason
    return await repo.update_user_plant(plant)

# --- US-022, US-026: Nhật Ký Sinh Trưởng & Báo Cáo ---
@router.post("/growth-logs", response_model=GrowthLogResponse, status_code=status.HTTP_201_CREATED)
async def add_growth_log(
    req: GrowthLogCreate,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-022: Ghi chép nhật ký phát triển của cây (chiều cao, đơm nụ, thay chậu) kèm hình ảnh"""
    from app.models.garden import PlantGrowthLog
    log_data = req.model_dump()
    if not log_data.get("log_date"):
        log_data["log_date"] = date.today()
    log = PlantGrowthLog(**log_data)
    return await repo.add_growth_log(log)

@router.get("/plants/{plant_id}/growth-logs", response_model=List[GrowthLogResponse])
async def get_growth_logs(
    plant_id: str,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    return await repo.get_growth_logs_by_plant(plant_id)

@router.get("/plants/{plant_id}/report")
async def export_plant_report(
    plant_id: str,
    current_user: User = Depends(get_current_active_user),
    schedule_service: SmartScheduleService = Depends(get_schedule_service)
):
    """US-026: Xuất báo cáo lịch sử chăm sóc cây ra dạng tệp tổng hợp để chia sẻ"""
    return await schedule_service.generate_plant_report(plant_id)

# --- US-027, US-029, US-032, US-035: Lịch Chăm Sóc Thông Minh ---
@router.get("/schedules", response_model=List[CareScheduleResponse])
async def get_smart_schedules(
    target_date: Optional[date] = None,
    current_user: User = Depends(get_current_active_user),
    schedule_service: SmartScheduleService = Depends(get_schedule_service)
):
    """US-027, US-032, US-035: Tự động sinh lịch tưới thích ứng và tự hoãn khi mưa lớn"""
    return await schedule_service.generate_smart_schedules_for_user(current_user.id, target_date)

@router.post("/schedules/{schedule_id}/action", response_model=CareScheduleResponse)
async def act_on_schedule(
    schedule_id: str,
    req: ScheduleActionRequest,
    current_user: User = Depends(get_current_active_user),
    schedule_service: SmartScheduleService = Depends(get_schedule_service)
):
    """US-029: Đánh dấu 'Đã tưới' (COMPLETE) hoặc 'Hoãn 1 ngày' (POSTPONE)"""
    return await schedule_service.perform_schedule_action(schedule_id, req.action, req.postpone_days)

# --- US-036: Chế Độ Đi Vắng / Nghỉ Dưỡng ---
@router.get("/vacation", response_model=VacationModeResponse)
async def get_vacation_mode(
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    return await repo.get_or_create_vacation_setting(current_user.id)

@router.put("/vacation", response_model=VacationModeResponse)
async def update_vacation_mode(
    req: VacationModeRequest,
    current_user: User = Depends(get_current_active_user),
    repo: GardenRepository = Depends(get_garden_repo)
):
    """US-036: Kích hoạt chế độ 'Đi vắng/Nghỉ dưỡng' để tạm dừng thông báo nhắc nhở"""
    setting = await repo.get_or_create_vacation_setting(current_user.id)
    setting.is_vacation_mode = req.is_vacation_mode
    setting.start_date = req.start_date
    setting.end_date = req.end_date
    setting.vacation_note = req.vacation_note
    return await repo.update_vacation_setting(setting)
