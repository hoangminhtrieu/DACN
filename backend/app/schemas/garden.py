from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from app.models.garden import LightRequirement, PlantDifficulty, ScheduleTaskType

# --- Plant Catalog Schemas ---
class PlantCatalogCreate(BaseModel):
    common_name_vi: str
    scientific_name: str
    plant_family: Optional[str] = None
    plant_category: str
    light_requirement: LightRequirement
    difficulty: PlantDifficulty = PlantDifficulty.EASY
    standard_water_interval_days: int = 2
    optimal_temperature_min: float = 18.0
    optimal_temperature_max: float = 32.0
    image_url: Optional[str] = None
    description: Optional[str] = None
    care_instructions: Optional[str] = None

class PlantCatalogResponse(PlantCatalogCreate):
    id: str

    class Config:
        from_attributes = True

# --- User Garden Schemas ---
class UserGardenCreate(BaseModel):
    garden_name: str
    location_tag: str
    is_outdoor: bool = True

class UserGardenResponse(UserGardenCreate):
    id: str
    user_id: str
    created_at: datetime

    class Config:
        from_attributes = True

# --- User Plant Schemas ---
class UserPlantCreate(BaseModel):
    garden_id: Optional[str] = None
    catalog_id: Optional[str] = None
    custom_name: str
    photo_url: Optional[str] = None
    location_tag: str = "Ban công hướng Đông"
    pot_size_cm: int = 25
    planted_date: Optional[date] = None
    custom_water_interval_days: Optional[int] = None

class UserPlantUpdate(BaseModel):
    custom_name: Optional[str] = None
    garden_id: Optional[str] = None
    location_tag: Optional[str] = None
    pot_size_cm: Optional[int] = None
    photo_url: Optional[str] = None
    health_status: Optional[str] = None
    custom_water_interval_days: Optional[int] = None

class UserPlantArchiveRequest(BaseModel):
    archive_reason: str = Field(..., description="'DEAD' (Đã chết), 'GIFTED' (Đã tặng), 'REMOVED'")

class UserPlantResponse(BaseModel):
    id: str
    user_id: str
    garden_id: Optional[str] = None
    catalog_id: Optional[str] = None
    custom_name: str
    photo_url: Optional[str] = None
    location_tag: str
    pot_size_cm: int
    planted_date: date
    health_status: str
    is_active: bool
    archive_reason: Optional[str] = None
    custom_water_interval_days: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

# --- Growth Log Schemas ---
class GrowthLogCreate(BaseModel):
    user_plant_id: str
    log_date: Optional[date] = None
    height_cm: Optional[float] = None
    growth_milestone: Optional[str] = None # Đơm nụ, Nở hoa, Thay chậu
    note: Optional[str] = None
    photo_url: Optional[str] = None

class GrowthLogResponse(GrowthLogCreate):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# --- Care Schedule Schemas ---
class CareScheduleResponse(BaseModel):
    id: str
    user_plant_id: str
    plant_name: Optional[str] = None
    task_type: ScheduleTaskType
    scheduled_date: date
    scheduled_time: str
    is_completed: bool
    completed_at: Optional[datetime] = None
    weather_skip_flag: bool
    skip_reason: Optional[str] = None

    class Config:
        from_attributes = True

class ScheduleActionRequest(BaseModel):
    action: str = Field(..., description="'COMPLETE' (Đã tưới) hoặc 'POSTPONE' (Hoãn 1 ngày)")
    postpone_days: int = 1

# --- Weather & Smart Forecast Schemas ---
class WeatherAlert(BaseModel):
    alert_type: str # 'HEAT_WAVE' (>38°C), 'COLD_WAVE' (<12°C), 'HEAVY_RAIN' (>70% / 15mm)
    severity: str   # 'WARNING', 'CRITICAL', 'INFO'
    title: str
    description: str
    recommended_action: str

class WeatherForecastResponse(BaseModel):
    city: str
    temperature_celsius: float
    humidity_percent: int
    rain_probability_percent: int
    weather_condition: str
    alerts: List[WeatherAlert] = []

# --- Vacation Mode Schemas ---
class VacationModeRequest(BaseModel):
    is_vacation_mode: bool
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    vacation_note: Optional[str] = None

class VacationModeResponse(VacationModeRequest):
    id: str
    user_id: str

    class Config:
        from_attributes = True
