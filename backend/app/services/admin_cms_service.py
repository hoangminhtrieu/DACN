import io
import csv
from datetime import datetime
from typing import List, Dict, Any, Optional

class AdminCmsService:
    def __init__(self):
        # US-093: Dữ liệu thống kê DAU/MAU và doanh thu
        self.metrics = {
            "dau": 14250, # Daily Active Users
            "mau": 89400, # Monthly Active Users
            "total_scans_today": 3280,
            "total_scans_all_time": 412500,
            "today_revenue_vnd": 18450000,
            "monthly_revenue_vnd": 342000000,
            "active_vip_subscribers": 4520,
            "expert_sessions_booked": 186
        }

        # US-094: Dữ liệu phân bố bản đồ nhiệt dịch bệnh theo từng quận/khu vực
        self.disease_heatmap_by_district = [
            {
                "city": "Hà Nội",
                "district": "Cầu Giấy",
                "lat": 21.0362,
                "lng": 105.7895,
                "top_disease": "Bệnh Phấn Trắng Hoa Hồng",
                "infection_count": 420,
                "severity_index": "HIGH",
                "weather_condition": "Độ ẩm 85%, sương đêm dày"
            },
            {
                "city": "Hà Nội",
                "district": "Ba Đình",
                "lat": 21.0425,
                "lng": 105.8182,
                "top_disease": "Đốm Đen Hoa Hồng",
                "infection_count": 290,
                "severity_index": "MEDIUM",
                "weather_condition": "Mưa rào ngắt quãng"
            },
            {
                "city": "TP. Hồ Chí Minh",
                "district": "Quận 3",
                "lat": 10.7812,
                "lng": 106.6924,
                "top_disease": "Nhện Đỏ Hại Kiểng Lá & Mai Vàng",
                "infection_count": 510,
                "severity_index": "CRITICAL",
                "weather_condition": "Nắng gắt 36°C, độ ẩm thấp"
            },
            {
                "city": "TP. Hồ Chí Minh",
                "district": "Thành phố Thủ Đức",
                "lat": 10.8494,
                "lng": 106.7717,
                "top_disease": "Rệp Sáp Trắng",
                "infection_count": 380,
                "severity_index": "HIGH",
                "weather_condition": "Kín gió, mật độ vườn dày"
            },
            {
                "city": "Đà Nẵng",
                "district": "Hải Châu",
                "lat": 16.0544,
                "lng": 108.2022,
                "top_disease": "Bệnh Thối Rễ Sen Đá",
                "infection_count": 195,
                "severity_index": "MEDIUM",
                "weather_condition": "Mưa bão ven biển"
            }
        ]

        # US-095: Bài viết cẩm nang CMS
        self.cms_articles = [
            {
                "id": "art_01",
                "title": "Bí quyết phòng trị bọ trĩ và nhện đỏ bằng dầu Neem ép lạnh an toàn cho gia đình",
                "category": "ORGANIC_TIPS",
                "author": "Ban Biên Tập Kỹ Thuật Urban Plants",
                "views": 15420,
                "status": "PUBLISHED"
            },
            {
                "id": "art_02",
                "title": "Hướng dẫn tự ủ vi sinh bản địa IMO4 tại ban công chung cư không mùi hôi",
                "category": "BIO_FERTILIZER",
                "author": "Kỹ sư Trần Anh Dũng",
                "views": 9850,
                "status": "PUBLISHED"
            }
        ]

        # US-096: Cập nhật mô hình AI ngầm (OTA Model Releases)
        self.ota_releases = [
            {
                "version": "v1.2.0-int8",
                "model_type": "TFLITE_INT8",
                "file_size_mb": 8.6,
                "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                "download_url": "https://cdn.urbanplants.vn/models/urban_plant_v1.2.0.tflite",
                "changelog": "Tăng cường nhận diện sâu bệnh trên Sen đá và Cà chua bi, giảm thêm 5% false positive.",
                "is_active": True,
                "released_at": "2026-10-23 08:00:00"
            }
        ]

        # US-097: Khiếu nại tư vấn chuyên gia
        self.disputes = [
            {
                "dispute_id": "disp_01",
                "booking_id": "BK_A1B2C3",
                "user_name": "Nguyễn Hoàng Minh",
                "expert_name": "Kỹ sư Trần Anh Dũng",
                "reason": "Mạng chập chờn trong 5 phút đầu buổi tư vấn",
                "status": "RESOLVED_REFUNDED_50_PERCENT",
                "resolution_note": "Đã hoàn lại 50% phí và tặng mã tư vấn bù 15 phút."
            }
        ]

    def get_dashboard_overview(self) -> Dict[str, Any]:
        """US-093: Tổng quan số liệu người dùng, lượt quét AI và doanh thu"""
        return self.metrics

    def get_disease_heatmap(self, city: Optional[str] = None) -> List[Dict[str, Any]]:
        """US-094: Dữ liệu bản đồ nhiệt lây lan dịch bệnh cây đô thị theo quận"""
        if city:
            return [d for d in self.disease_heatmap_by_district if d["city"].lower() == city.lower()]
        return self.disease_heatmap_by_district

    def get_latest_ota_model(self) -> Dict[str, Any]:
        """US-096: Kiểm tra phiên bản mô hình AI TFLite mới nhất để tải ngầm OTA"""
        active_releases = [r for r in self.ota_releases if r["is_active"]]
        return active_releases[-1] if active_releases else self.ota_releases[0]

    def publish_new_ota_model(
        self,
        version: str,
        file_size_mb: float,
        checksum: str,
        download_url: str,
        changelog: str
    ) -> Dict[str, Any]:
        """US-096: Admin xuất bản phiên bản AI mới lên CDN"""
        new_rel = {
            "version": version,
            "model_type": "TFLITE_INT8",
            "file_size_mb": file_size_mb,
            "checksum_sha256": checksum,
            "download_url": download_url,
            "changelog": changelog,
            "is_active": True,
            "released_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.ota_releases.append(new_rel)
        return new_rel

    def export_analytics_csv(self) -> str:
        """US-098: Xuất dữ liệu thống kê lượt quét và doanh thu ra tệp CSV/Excel"""
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["Mã Quận", "Thành Phố", "Bệnh Phổ Biến Nhất", "Số Ca Nhiễm", "Mức Độ Cảnh Báo", "Điều Kiện Thời Tiết"])
        for item in self.disease_heatmap_by_district:
            writer.writerow([
                item["district"],
                item["city"],
                item["top_disease"],
                item["infection_count"],
                item["severity_index"],
                item["weather_condition"]
            ])
        return output.getvalue()

admin_cms_service = AdminCmsService()
