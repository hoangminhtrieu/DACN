import uuid
import math
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional

class CommerceService:
    def __init__(self):
        # US-083: Kho sản phẩm liên kết Affiliate chuẩn Safe-First
        self.affiliate_catalog = [
            {
                "id": "prod_neem_oil_01",
                "disease_code": "Rose___Powdery_Mildew",
                "product_name": "Dầu Neem Ép Lạnh Nguyên Chất Docneem 100ml",
                "brand": "Docneem",
                "category": "ORGANIC_REMEDY",
                "price_vnd": 85000,
                "platform": "SHOPEE",
                "affiliate_url": "https://shopee.vn/universal-link/docneem-pure-cold-pressed?aff_id=urbanplants_01",
                "commission_rate": 0.08,
                "safe_first_label": "Hữu cơ sinh học - 100% an toàn ban công"
            },
            {
                "id": "prod_bacillus_02",
                "disease_code": "Rose___Black_Spot",
                "product_name": "Chế Phẩm Vi Sinh Bacillus Subtilis Phòng Trị Nấm Lá",
                "brand": "Bio-Green",
                "category": "BIO_ACTIVE",
                "price_vnd": 65000,
                "platform": "LAZADA",
                "affiliate_url": "https://lazada.vn/universal-link/bacillus-subtilis-bio?aff_id=urbanplants_01",
                "commission_rate": 0.10,
                "safe_first_label": "Vi sinh đối kháng - Không mùi, không hóa chất"
            },
            {
                "id": "prod_fe_eddha_03",
                "disease_code": "General___Iron_Deficiency_Chlorosis",
                "product_name": "Sắt Chelate Fe-EDDHA 6% Chống Vàng Lá Gân Xanh",
                "brand": "Agri-Care",
                "category": "MICRONUTRIENT",
                "price_vnd": 45000,
                "platform": "TIKTOK_SHOP",
                "affiliate_url": "https://vt.tiktok.com/urbanplants_fe_eddha",
                "commission_rate": 0.08,
                "safe_first_label": "Vi lượng cao cấp - Hấp thụ nhanh qua rễ"
            },
            {
                "id": "prod_shears_04",
                "disease_code": "ALL",
                "product_name": "Kéo Cắt Tỉa Cành Thép SK5 Nhật Bản Chống Gỉ",
                "brand": "Sada",
                "category": "TOOL",
                "price_vnd": 120000,
                "platform": "SHOPEE",
                "affiliate_url": "https://shopee.vn/universal-link/sk5-shears?aff_id=urbanplants_01",
                "commission_rate": 0.12,
                "safe_first_label": "Dụng cụ chuẩn cách ly cành bệnh"
            }
        ]

        # US-084: Danh mục cửa hàng vật tư nông nghiệp đô thị
        self.stores_database = [
            {
                "id": "store_01",
                "name": "Nông Nghiệp Phố - Chi nhánh Cầu Giấy",
                "address": "Số 10A Nguyễn Phong Sắc, Dịch Vọng, Cầu Giấy",
                "district": "Cầu Giấy",
                "city": "Hà Nội",
                "lat": 21.0362,
                "lng": 105.7895,
                "phone": "0968 123 456",
                "rating": 4.9,
                "verified_partner": True
            },
            {
                "id": "store_02",
                "name": "Trạm Xanh Nông Nghiệp Đô Thị",
                "address": "84 Hoàng Hoa Thám, Ba Đình",
                "district": "Ba Đình",
                "city": "Hà Nội",
                "lat": 21.0425,
                "lng": 105.8182,
                "phone": "0912 345 678",
                "rating": 4.8,
                "verified_partner": True
            },
            {
                "id": "store_03",
                "name": "Vườn Xanh Ban Công Sài Gòn",
                "address": "128 Nguyễn Đình Chiểu, Phường 6, Quận 3",
                "district": "Quận 3",
                "city": "TP. Hồ Chí Minh",
                "lat": 10.7812,
                "lng": 106.6924,
                "phone": "0903 888 999",
                "rating": 4.9,
                "verified_partner": True
            }
        ]

        # US-089: Danh sách chuyên gia cây cảnh tư vấn 1-1
        self.experts_database = [
            {
                "expert_id": "exp_01",
                "name": "Kỹ sư Trần Anh Dũng",
                "title": "Chuyên gia Bệnh cây trồng Đô thị & Hoa Hồng",
                "experience_years": 12,
                "rating": 4.98,
                "reviews_count": 342,
                "hourly_rate_vnd": 99000, # 99k / 30 phút
                "available_slots": ["09:00", "10:30", "14:30", "16:00", "19:30"]
            },
            {
                "expert_id": "exp_02",
                "name": "Thạc sĩ Lê Thu Thảo",
                "title": "Chuyên gia Kiểng lá Đột biến & Sen đá Khí hậu nóng",
                "experience_years": 8,
                "rating": 4.95,
                "reviews_count": 215,
                "hourly_rate_vnd": 99000,
                "available_slots": ["08:30", "11:00", "15:00", "17:30", "20:00"]
            }
        ]

        self.transactions_db = []
        self.consultations_db = []

    def get_affiliate_products(self, disease_code: Optional[str] = None) -> List[Dict[str, Any]]:
        """US-083: Lấy sản phẩm thuốc sinh học/phân bón theo bệnh cây vừa quét"""
        if disease_code:
            matches = [p for p in self.affiliate_catalog if p["disease_code"] in (disease_code, "ALL")]
            if matches:
                return matches
        return self.affiliate_catalog

    def find_nearest_stores(self, user_lat: float, user_lng: float, limit: int = 5) -> List[Dict[str, Any]]:
        """US-084: Tìm cửa hàng vật tư gần vị trí hiện tại của người dùng nhất"""
        def haversine(lat1, lon1, lat2, lon2):
            R = 6371.0 # Bán kính trái đất (km)
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            return round(R * c, 2)

        results = []
        for s in self.stores_database:
            dist_km = haversine(user_lat, user_lng, s["lat"], s["lng"])
            s_copy = dict(s)
            s_copy["distance_km"] = dist_km
            results.append(s_copy)

        results.sort(key=lambda x: x["distance_km"])
        return results[:limit]

    def create_payment_order(
        self,
        user_id: str,
        transaction_type: str,
        amount_vnd: int,
        payment_method: str
    ) -> Dict[str, Any]:
        """
        US-085, US-086: Khởi tạo thanh toán VietQR động, MoMo hoặc ZaloPay.
        Gói Pro 29k/tháng hoặc 299k/năm.
        """
        txn_id = f"TXN_{uuid.uuid4().hex[:10].upper()}"
        invoice_no = f"INV-UP-{datetime.utcnow().strftime('%Y%m%d')}-{uuid.uuid4().hex[:6].upper()}"

        # Tạo URL VietQR động theo chuẩn Napas247 (VietinBank / MBBank)
        vietqr_url = (
            f"https://img.vietqr.io/image/MB-0968888999-compact2.png"
            f"?amount={amount_vnd}&addInfo={txn_id}&accountName=CONG%20TY%20URBAN%20PLANTS"
        )

        txn = {
            "transaction_id": txn_id,
            "invoice_number": invoice_no,
            "user_id": user_id,
            "transaction_type": transaction_type,
            "amount_vnd": amount_vnd,
            "payment_method": payment_method,
            "status": "COMPLETED", # Môi trường sandbox hoàn tất tức thì
            "qr_code_url": vietqr_url if payment_method == "VIETQR" else None,
            "deeplink_app": f"momo://app?action=pay&amount={amount_vnd}" if payment_method == "MOMO" else f"zalopay://pay?amount={amount_vnd}",
            "created_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
            "completed_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.transactions_db.append(txn)
        return txn

    def book_expert_consultation(
        self,
        user_id: str,
        expert_id: str,
        plant_name: str,
        symptoms: str,
        meeting_time: str
    ) -> Dict[str, Any]:
        """
        US-087, US-088: Đặt lịch tư vấn 1-1 qua Video Call với Chuyên gia cây trồng.
        """
        room_id = f"urban-room-{uuid.uuid4().hex[:8]}"
        consultation = {
            "booking_id": f"BK_{uuid.uuid4().hex[:8].upper()}",
            "user_id": user_id,
            "expert_id": expert_id,
            "plant_name": plant_name,
            "symptoms_summary": symptoms,
            "meeting_time": meeting_time,
            "fee_vnd": 99000,
            "status": "CONFIRMED",
            "video_call_room_url": f"https://meet.urbanplants.vn/{room_id}",
            "created_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.consultations_db.append(consultation)
        return consultation

    def list_user_transactions(self, user_id: str) -> List[Dict[str, Any]]:
        """US-092: Lịch sử giao dịch và hóa đơn điện tử e-receipt"""
        return [t for t in self.transactions_db if t["user_id"] == user_id]

    def calculate_affiliate_commission(self, order_value_vnd: int, rate: float = 0.08) -> Dict[str, Any]:
        """US-091: Tự động tính toán hoa hồng từ đơn hàng Affiliate"""
        commission = int(order_value_vnd * rate)
        return {
            "order_value_vnd": order_value_vnd,
            "commission_rate": rate,
            "commission_amount_vnd": commission,
            "recorded_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        }

commerce_service = CommerceService()
