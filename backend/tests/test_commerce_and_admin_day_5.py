import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.services.commerce_service import commerce_service
from app.services.admin_cms_service import admin_cms_service

class TestDay5CommerceAndAdmin(unittest.TestCase):

    def test_us_083_affiliate_products(self):
        """US-083: Mua chế phẩm sinh học qua liên kết Shopee/Lazada Affiliate"""
        prods = commerce_service.get_affiliate_products("Rose___Powdery_Mildew")
        self.assertGreaterEqual(len(prods), 1)
        self.assertIn("affiliate_url", prods[0])
        self.assertIn("safe_first_label", prods[0])

    def test_us_084_nearest_stores_gps(self):
        """US-084: Tìm cửa hàng vật tư gần nhất theo tọa độ GPS"""
        # Tọa độ tại Cầu Giấy, Hà Nội
        stores = commerce_service.find_nearest_stores(user_lat=21.0362, user_lng=105.7895, limit=3)
        self.assertGreaterEqual(len(stores), 1)
        self.assertIn("distance_km", stores[0])
        self.assertLess(stores[0]["distance_km"], 5.0)

    def test_us_085_086_payment_vietqr(self):
        """US-085, US-086: Khởi tạo thanh toán VietQR động gói VIP Pro"""
        order = commerce_service.create_payment_order(
            user_id="user_test_01",
            transaction_type="VIP_PRO_MONTHLY",
            amount_vnd=29000,
            payment_method="VIETQR"
        )
        self.assertEqual(order["amount_vnd"], 29000)
        self.assertIn("vietqr.io", order["qr_code_url"])
        self.assertIn("INV-UP", order["invoice_number"])

    def test_us_087_088_expert_booking(self):
        """US-087, US-088: Đặt lịch tư vấn 1-1 với Chuyên gia qua Video Call"""
        booking = commerce_service.book_expert_consultation(
            user_id="user_test_01",
            expert_id="exp_01",
            plant_name="Hoa hồng Claude Monet",
            symptoms="Đốm đen lá lan rộng",
            meeting_time="2026-10-23 14:30:00"
        )
        self.assertEqual(booking["fee_vnd"], 99000)
        self.assertEqual(booking["status"], "CONFIRMED")
        self.assertIn("meet.urbanplants.vn", booking["video_call_room_url"])

    def test_us_091_affiliate_commission(self):
        """US-091: Tự động tính toán hoa hồng từ đơn hàng Affiliate"""
        res = commerce_service.calculate_affiliate_commission(order_value_vnd=200000, rate=0.08)
        self.assertEqual(res["commission_amount_vnd"], 16000)

    def test_us_093_dashboard_metrics(self):
        """US-093: Bảng điều khiển tổng quan DAU/MAU và Doanh thu"""
        metrics = admin_cms_service.get_dashboard_overview()
        self.assertGreater(metrics["dau"], 10000)
        self.assertGreater(metrics["mau"], 50000)
        self.assertGreater(metrics["today_revenue_vnd"], 0)

    def test_us_094_disease_heatmap_by_district(self):
        """US-094: Bản đồ nhiệt lây lan dịch bệnh theo quận"""
        heatmap_hn = admin_cms_service.get_disease_heatmap(city="Hà Nội")
        self.assertGreaterEqual(len(heatmap_hn), 2)
        self.assertIn("Cầu Giấy", [d["district"] for d in heatmap_hn])

    def test_us_096_ota_model_update(self):
        """US-096: Cập nhật mô hình AI ngầm OTA"""
        latest = admin_cms_service.get_latest_ota_model()
        self.assertEqual(latest["version"], "v1.2.0-int8")
        self.assertTrue(latest["is_active"])

    def test_us_098_export_analytics_csv(self):
        """US-098: Xuất báo cáo dữ liệu dịch bệnh ra CSV"""
        csv_text = admin_cms_service.export_analytics_csv()
        self.assertIn("Mã Quận", csv_text)
        self.assertIn("Bệnh Phổ Biến Nhất", csv_text)

if __name__ == "__main__":
    unittest.main()
