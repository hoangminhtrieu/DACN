from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from app.services.commerce_service import commerce_service, CommerceService

router = APIRouter(prefix="/commerce", tags=["Commerce, Affiliate, Stores & Expert Consultation"])

class PaymentOrderRequest(BaseModel):
    user_id: str
    transaction_type: str # VIP_PRO_MONTHLY, VIP_PRO_YEARLY, EXPERT_CONSULTATION
    amount_vnd: int
    payment_method: str # VIETQR, MOMO, ZALOPAY

class BookConsultationRequest(BaseModel):
    user_id: str
    expert_id: str
    plant_name: str
    symptoms: str
    meeting_time: str

@router.get("/affiliate-products")
def get_affiliate_products(disease_code: Optional[str] = None):
    """US-083: Mua chế phẩm sinh học/phân bón qua liên kết Shopee/Lazada Affiliate"""
    return commerce_service.get_affiliate_products(disease_code)

@router.get("/nearest-stores")
def get_nearest_stores(
    lat: float = Query(21.0362, description="Vĩ độ hiện tại"),
    lng: float = Query(105.7895, description="Kinh độ hiện tại"),
    limit: int = Query(5, description="Số lượng cửa hàng trả về")
):
    """US-084: Danh sách cửa hàng vật tư nông nghiệp đô thị uy tín gần vị trí nhất"""
    return commerce_service.find_nearest_stores(lat, lng, limit)

@router.post("/payment/create-order")
def create_payment_order(req: PaymentOrderRequest):
    """
    US-085: Đăng ký gói VIP Urban Plants Pro (29k/tháng hoặc 299k/năm).
    US-086: Cổng thanh toán VietQR động, MoMo hoặc ZaloPay.
    """
    return commerce_service.create_payment_order(
        user_id=req.user_id,
        transaction_type=req.transaction_type,
        amount_vnd=req.amount_vnd,
        payment_method=req.payment_method
    )

@router.post("/expert/book")
def book_expert_consultation(req: BookConsultationRequest):
    """
    US-087, US-088: Đặt lịch và thanh toán tư vấn 1-1 qua Video Call với Chuyên gia.
    """
    return commerce_service.book_expert_consultation(
        user_id=req.user_id,
        expert_id=req.expert_id,
        plant_name=req.plant_name,
        symptoms=req.symptoms,
        meeting_time=req.meeting_time
    )

@router.get("/transactions/{user_id}")
def get_user_transactions(user_id: str):
    """US-092: Xem lịch sử giao dịch và hóa đơn điện tử e-receipt"""
    return commerce_service.list_user_transactions(user_id)
