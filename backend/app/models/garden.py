import enum
import uuid
from datetime import datetime, date
from typing import Optional, List
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Date, Text, Enum, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class LightRequirement(str, enum.Enum):
    DIRECT_SUN = "DIRECT_SUN"             # Nắng trực tiếp (>6h/ngày, vd: Hoa hồng, Cà chua, Ớt)
    PARTIAL_SHADE = "PARTIAL_SHADE"       # Nắng bán phần / Nắng nhẹ (3-5h/ngày, vd: Sen đá)
    INDIRECT_BRIGHT = "INDIRECT_BRIGHT"   # Ánh sáng tán xạ gián tiếp (vd: Kiểng lá Monstera)
    LOW_LIGHT = "LOW_LIGHT"               # Ánh sáng yếu / Trong nhà (vd: Trầu bà, Kim tiền)

class PlantDifficulty(str, enum.Enum):
    EASY = "EASY"
    MEDIUM = "MEDIUM"
    HARD = "HARD"

class ScheduleTaskType(str, enum.Enum):
    WATERING = "WATERING"
    FERTILIZING = "FERTILIZING"
    PRUNING = "PRUNING"
    SUN_ROTATION = "SUN_ROTATION"

# US-016: Danh mục cây trồng đô thị mẫu chuẩn
class PlantCatalog(Base):
    __tablename__ = "plants_catalog"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    common_name_vi = Column(String(150), nullable=False, index=True)   # Hoa hồng, Sen đá, Monstera...
    scientific_name = Column(String(150), nullable=False, index=True)
    plant_family = Column(String(100), nullable=True)                  # Họ Hoa hồng (Rosaceae)...
    plant_category = Column(String(50), nullable=False)                # Cây hoa, Kiểng lá, Mọng nước, Rau quả
    
    light_requirement = Column(Enum(LightRequirement), nullable=False)
    difficulty = Column(Enum(PlantDifficulty), default=PlantDifficulty.EASY, nullable=False)
    
    standard_water_interval_days = Column(Integer, default=2, nullable=False) # Chu kỳ tưới chuẩn
    optimal_temperature_min = Column(Float, default=18.0)
    optimal_temperature_max = Column(Float, default=32.0)
    
    image_url = Column(String(500), nullable=True)
    description = Column(Text, nullable=True)
    care_instructions = Column(Text, nullable=True)

# US-019 & US-025: Khu Vườn & Góc Vườn của người dùng
class UserGarden(Base):
    __tablename__ = "user_gardens"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    garden_name = Column(String(100), nullable=False)                  # Vườn Ban công, Vườn Sân thượng...
    location_tag = Column(String(50), nullable=False)                 # Ban công Đông, Sân thượng, Bậu cửa...
    is_outdoor = Column(Boolean, default=True, nullable=False)         # Ngoài trời (chịu ảnh hưởng của mưa)
    created_at = Column(DateTime, default=datetime.utcnow)

# US-019, US-020, US-021, US-023, US-024: Chậu cây của tôi
class UserPlant(Base):
    __tablename__ = "user_plants"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    garden_id = Column(String(36), ForeignKey("user_gardens.id", ondelete="SET NULL"), nullable=True)
    catalog_id = Column(String(36), ForeignKey("plants_catalog.id", ondelete="SET NULL"), nullable=True)
    
    custom_name = Column(String(150), nullable=False)                 # vd: "Em Hồng Leo Mon Coeur"
    photo_url = Column(String(500), nullable=True)
    location_tag = Column(String(100), default="Ban công hướng Đông")  # Ban công Đông, Phòng khách...
    pot_size_cm = Column(Integer, default=25)                         # Kích thước chậu
    planted_date = Column(Date, default=date.today)
    
    health_status = Column(String(50), default="HEALTHY")              # HEALTHY, SICK, RECOVERING, DEAD
    is_active = Column(Boolean, default=True, nullable=False)          # False khi xóa hoặc cho/tặng
    archive_reason = Column(String(100), nullable=True)                # DEAD, GIFTED, REMOVED
    
    custom_water_interval_days = Column(Integer, nullable=True)        # US-030: Tùy chỉnh chu kỳ tưới
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# US-022: Nhật ký sinh trưởng cây (Timeline & Báo cáo)
class PlantGrowthLog(Base):
    __tablename__ = "plant_growth_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_plant_id = Column(String(36), ForeignKey("user_plants.id", ondelete="CASCADE"), nullable=False)
    log_date = Column(Date, default=date.today, nullable=False)
    
    height_cm = Column(Float, nullable=True)                           # Chiều cao cây
    growth_milestone = Column(String(100), nullable=True)              # Đơm nụ, Nở hoa, Ra chồi mới, Thay chậu
    note = Column(Text, nullable=True)
    photo_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# US-027, US-029, US-032: Lịch chăm sóc thông minh thích ứng thời tiết
class CareSchedule(Base):
    __tablename__ = "care_schedules"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_plant_id = Column(String(36), ForeignKey("user_plants.id", ondelete="CASCADE"), nullable=False)
    task_type = Column(Enum(ScheduleTaskType), default=ScheduleTaskType.WATERING, nullable=False)
    
    scheduled_date = Column(Date, nullable=False)
    scheduled_time = Column(String(10), default="07:00")               # 07:00 sáng
    
    is_completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime, nullable=True)
    
    # Thích ứng thời tiết & hoãn tưới
    weather_skip_flag = Column(Boolean, default=False, nullable=False) # Tự hoãn khi mưa lớn
    skip_reason = Column(String(255), nullable=True)                   # "Mưa lớn 25mm, độ ẩm 90% - Tự hoãn tránh úng"
    
    created_at = Column(DateTime, default=datetime.utcnow)

# US-036: Chế độ Đi vắng / Nghỉ dưỡng của người dùng
class UserVacationSetting(Base):
    __tablename__ = "user_vacation_settings"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    is_vacation_mode = Column(Boolean, default=False, nullable=False)
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    vacation_note = Column(String(255), nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
