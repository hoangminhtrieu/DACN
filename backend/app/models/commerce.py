import enum
import uuid
from datetime import datetime, date
try:
    from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Date, Text, Enum, ForeignKey
    from app.core.database import Base
except ImportError:
    class Base: pass
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

class PaymentMethod(str, enum.Enum):
    VIETQR = "VIETQR"
    MOMO = "MOMO"
    ZALOPAY = "ZALOPAY"

class PaymentStatus(str, enum.Enum):
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"

class SubscriptionTier(str, enum.Enum):
    FREE = "FREE"
    PRO_MONTHLY = "PRO_MONTHLY" # 29.000đ / tháng
    PRO_YEARLY = "PRO_YEARLY"   # 299.000đ / năm

class ConsultationStatus(str, enum.Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"

# US-083, US-090, US-091: Sản phẩm vật tư nông nghiệp & Liên kết Affiliate
class AffiliateProduct(Base):
    __tablename__ = "affiliate_products"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    disease_code = Column(String(100), nullable=True, index=True) # Liên kết bệnh đề xuất
    product_name = Column(String(200), nullable=False)
    brand = Column(String(100), nullable=False)
    category = Column(String(50), nullable=False) # BIO_PESTICIDE, FERTILIZER, NEEM_OIL, TOOL
    price_vnd = Column(Integer, nullable=False)
    platform = Column(String(50), nullable=False) # SHOPEE, LAZADA, TIKTOK_SHOP
    affiliate_url = Column(String(500), nullable=False)
    commission_rate = Column(Float, default=0.08) # 8% hoa hồng (US-091)
    is_safe_certified = Column(Boolean, default=True) # Đạt chuẩn Safe-First

# US-084: Danh mục cửa hàng vật tư nông nghiệp đô thị gần nhất
class GardeningStore(Base):
    __tablename__ = "gardening_stores"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(200), nullable=False)
    address = Column(String(300), nullable=False)
    district = Column(String(100), nullable=False)
    city = Column(String(100), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    phone = Column(String(20), nullable=False)
    rating = Column(Float, default=4.8)
    verified_partner = Column(Boolean, default=True)

# US-085, US-086, US-092: Giao dịch thanh toán & Hóa đơn điện tử
class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), nullable=False, index=True)
    amount_vnd = Column(Integer, nullable=False)
    payment_method = Column(Enum(PaymentMethod), nullable=False)
    status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    transaction_type = Column(String(50), nullable=False) # VIP_PRO, CONSULTATION, AFFILIATE_COMMISSION
    qr_code_url = Column(String(500), nullable=True) # VietQR động
    invoice_number = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)

# US-087, US-088, US-089: Lịch tư vấn 1-1 với Chuyên gia cây trồng
class ExpertConsultation(Base):
    __tablename__ = "expert_consultations"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), nullable=False)
    expert_id = Column(String(36), nullable=False)
    plant_name = Column(String(100), nullable=False)
    symptoms_summary = Column(Text, nullable=False)
    meeting_time = Column(DateTime, nullable=False)
    fee_vnd = Column(Integer, default=99000) # 99k / buổi tư vấn 30 phút
    status = Column(Enum(ConsultationStatus), default=ConsultationStatus.PENDING)
    video_call_room_url = Column(String(300), nullable=True)
    expert_note = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# US-096: Cập nhật mô hình AI ngầm (OTA Model Update)
class ModelRelease(Base):
    __tablename__ = "model_releases"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    version = Column(String(50), unique=True, nullable=False) # v1.2.0
    model_type = Column(String(50), default="TFLITE_INT8")
    file_size_bytes = Column(Integer, nullable=False)
    download_url = Column(String(500), nullable=False)
    checksum_sha256 = Column(String(64), nullable=False)
    changelog = Column(Text, nullable=False)
    is_active = Column(Boolean, default=True)
    released_at = Column(DateTime, default=datetime.utcnow)
