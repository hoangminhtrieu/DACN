import enum
import uuid
from datetime import datetime, date
try:
    from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Date, Text, Enum, ForeignKey
    from app.core.database import Base
except ImportError:
    # Dummy fallback cho các môi trường chạy unit test logic thuần túy không có SQLAlchemy
    class Base:
        pass
    def Column(*args, **kwargs): return None
    def String(*args, **kwargs): return None
    def Integer(*args, **kwargs): return None
    def Float(*args, **kwargs): return None
    def Boolean(*args, **kwargs): return None
    def DateTime(*args, **kwargs): return None
    def Date(*args, **kwargs): return None
    def Text(*args, **kwargs): return None
    def Enum(*args, **kwargs): return None
    def ForeignKey(*args, **kwargs): return None

class PathogenCategory(str, enum.Enum):
    FUNGUS = "FUNGUS"                                 # Nấm bệnh (Phấn trắng, đốm đen, rỉ sắt)
    INSECT_PEST = "INSECT_PEST"                       # Côn trùng chích hút (Nhện đỏ, bọ trĩ, rệp sáp)
    NUTRIENT_DEFICIENCY = "NUTRIENT_DEFICIENCY"       # Thiếu vi chất dinh dưỡng (Sắt, Magie, Đạm)
    PHYSIOLOGICAL = "PHYSIOLOGICAL"                   # Sinh lý môi trường (Cháy nắng, đọng vôi nước)

class SpreadRisk(str, enum.Enum):
    HIGH = "HIGH"                                     # Nguy cơ lây lan nhanh sang các chậu lân cận
    MEDIUM = "MEDIUM"                                 # Nguy cơ lây lan trung bình
    NONE = "NONE"                                     # Không truyền nhiễm (do thiếu vi chất)

# US-059, US-060, US-062, US-063: Câu hỏi kiểm chứng chéo
class DiseaseDifferentialQuestion(Base):
    __tablename__ = "disease_differential_questions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    disease_code = Column(String(100), nullable=False, index=True) # Rose___Powdery_Mildew...
    question_text = Column(String(300), nullable=False)
    verification_target = Column(String(100), nullable=False)      # Tách nấm vs bọ trĩ vs đọng vôi
    sample_illustration_url = Column(String(500), nullable=True)   # US-060: Ảnh mẫu minh họa triệu chứng
    
    weight_positive = Column(Float, default=0.15)                  # Trọng số cộng nếu 'Có'
    weight_negative = Column(Float, default=-0.25)                 # Trọng số phạt nếu 'Không'
    created_at = Column(DateTime, default=datetime.utcnow)

# US-075 .. US-082: Phác đồ điều trị Safe-First 3 tầng
class TreatmentProtocol(Base):
    __tablename__ = "treatment_protocols"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    disease_code = Column(String(100), unique=True, nullable=False, index=True)
    disease_name_vi = Column(String(150), nullable=False)
    scientific_name = Column(String(150), nullable=False)
    pathogen_type = Column(Enum(PathogenCategory), nullable=False)
    spread_risk = Column(Enum(SpreadRisk), default=SpreadRisk.MEDIUM, nullable=False)
    incubation_period_days = Column(String(50), default="3 - 7 ngày") # US-065: Thời gian ủ bệnh

    # Phác đồ Safe-First 3 bước tuần tự (Quy chuẩn urban-plant-trust-protocol)
    step_1_isolation_pruning = Column(Text, nullable=False)
    step_2_organic_home_remedy = Column(Text, nullable=False)
    step_3_bio_pesticide = Column(Text, nullable=False)
    
    dosage_formula = Column(String(300), nullable=False)           # US-078: Tỷ lệ pha chi tiết ml/Lít
    spray_timing = Column(String(200), default="6h - 7h sáng hoặc 17h - 18h chiều mát")
    pet_and_child_safety_warning = Column(Text, nullable=False)    # US-079: Cảnh báo an toàn trẻ & thú cưng
    
    created_at = Column(DateTime, default=datetime.utcnow)

# US-081: Nhật ký theo dõi phục hồi sau 7 ngày
class RecoveryAudit(Base):
    __tablename__ = "recovery_audits"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_plant_id = Column(String(36), ForeignKey("user_plants.id", ondelete="CASCADE"), nullable=False)
    diagnosis_id = Column(String(100), nullable=False)
    day_number = Column(Integer, default=7)                        # Ngày thứ 7 sau điều trị
    before_image_url = Column(String(500), nullable=True)
    after_image_url = Column(String(500), nullable=True)
    recovery_status = Column(String(50), default="IMPROVED")       # RECOVERED, IMPROVED, UNCHANGED, WORSENED
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
