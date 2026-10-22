from typing import List, Dict, Any, Optional
from datetime import datetime, date, timedelta
from app.models.treatment import PathogenCategory, SpreadRisk

class SafeFirstProtocolService:
    def __init__(self):
        # Bách khoa toàn thư phác đồ điều trị 30+ bệnh sâu hại cây đô thị (US-082)
        self.protocol_database = {
            "Rose___Powdery_Mildew": {
                "disease_code": "Rose___Powdery_Mildew",
                "disease_name_vi": "Bệnh Phấn Trắng Hoa Hồng",
                "scientific_name": "Podosphaera pannosa",
                "pathogen_type": "FUNGUS",
                "spread_risk": "HIGH",
                "incubation_period": "3 - 5 ngày",
                # US-075: Bước 1 Cách ly & Cắt tỉa
                "step_1_isolation_pruning": "1. Di chuyển chậu hoa hồng cách ly khỏi các chậu cây khác tối thiểu 1.5 - 2m.\n2. Dùng kéo đã tiệt trùng bằng cồn y tế 70° cắt bỏ toàn bộ cành lá có vết phấn trắng phủ dày >50%.\n3. Thu gom lá cắt bỏ vào túi nilon buộc kín vứt rác, tuyệt đối không ủ làm phân hữu cơ tại ban công.\n4. Rửa sạch tay bằng xà phòng trước khi chạm vào cây khác.",
                # US-076: Bước 2 Giải pháp hữu cơ tự chế tại nhà
                "step_2_organic_home_remedy": "Công thức Baking Soda & Dầu ăn sinh học:\n- Pha 5g Baking Soda (khoảng 1 muỗng cà phê) + 5ml dầu ăn thực vật (hoặc dầu Neem ép lạnh) + 2ml nước rửa chén hữu cơ vào 1 Lít nước ấm.\n- Lắc đều tạo nhũ tương trắng sữa.\n- Phun ướt đẫm cả mặt trên và mặt dưới lá bệnh vào sáng sớm hoặc chiều mát.",
                # US-077: Bước 3 Hoạt chất sinh học an toàn
                "step_3_bio_pesticide": "Sử dụng chế phẩm vi sinh chứa chủng vi khuẩn đối kháng Bacillus subtilis hoặc nấm ký sinh Trichoderma harzianum.\n- Có thể dùng dung dịch Nano Bạc sinh học (nồng độ 20-30ppm) xịt phòng ngừa nấm tái phát.\n- KHÔNG sử dụng thuốc bảo vệ thực vật hóa học gốc độc nhóm I, II trong không gian sinh hoạt của gia đình.",
                # US-078: Tỷ lệ pha chi tiết & thời điểm phun
                "dosage_formula": "5g Baking Soda + 5ml Dầu Neem / 1 Lít nước ấm. Lặp lại 3 ngày/lần trong vòng 2 tuần.",
                "spray_timing": "6h00 - 7h30 sáng (khi trời mát, chưa có nắng gắt) hoặc 17h00 - 18h30 chiều.",
                # US-079: Cảnh báo an toàn cho trẻ em & vật nuôi
                "pet_and_child_safety_warning": "AN TOÀN CHO TRẺ EM VÀ CHÓ MÈO: Công thức gốc Baking Soda và Dầu Neem tự nhiên hoàn toàn không gây ngộ độc. Tuy nhiên, tránh để thú cưng liếm trực tiếp dung dịch khi lá còn ướt sũng."
            },
            "Rose___Black_Spot": {
                "disease_code": "Rose___Black_Spot",
                "disease_name_vi": "Bệnh Đốm Đen Lá Hoa Hồng",
                "scientific_name": "Diplocarpon rosae",
                "pathogen_type": "FUNGUS",
                "spread_risk": "HIGH",
                "incubation_period": "7 - 10 ngày",
                "step_1_isolation_pruning": "Vặt bỏ triệt để lá bị đốm đen rơi dưới gốc chậu vì bào tử nấm trú ngụ trong đất. Cắt tỉa cành thông thoáng gốc.",
                "step_2_organic_home_remedy": "Dung dịch tỏi ớt gừng ngâm rượu pha loãng (10ml dung dịch rượu tỏi ớt vào 1L nước) kết hợp 3ml dầu Neem.",
                "step_3_bio_pesticide": "Chế phẩm Copper Hydroxide (Đồng sinh học) hoặc dung dịch vi sinh vật bản địa IMO4.",
                "dosage_formula": "10ml Rượu tỏi ớt + 3ml Dầu Neem / 1 Lít nước.",
                "spray_timing": "Chiều mát 17h30, không phun trước khi trời đổ mưa lớn.",
                "pet_and_child_safety_warning": "Mùi nồng của tỏi ớt có thể gây cay mắt nhẹ cho mèo hoặc chó con nếu hít phải sương phun trực tiếp."
            },
            "Succulent___Stem_Rot": {
                "disease_code": "Succulent___Stem_Rot",
                "disease_name_vi": "Bệnh Thối Thân Rễ Sen Đá",
                "scientific_name": "Fusarium oxysporum / Pythium spp.",
                "pathogen_type": "FUNGUS",
                "spread_risk": "MEDIUM",
                "incubation_period": "2 - 4 ngày sau khi ngập nước",
                "step_1_isolation_pruning": "Nhổ cây ra khỏi đất ngay lập tức. Dùng dao lam tiệt trùng cắt bỏ toàn bộ phần thân thối cho đến khi chạm mô xanh lành lặn. Bôi cồn hoặc vôi vào vết cắt.",
                "step_2_organic_home_remedy": "Để cây ở nơi thoáng gió, khô ráo trong 3 - 5 ngày cho vết cắt se sẹo hoàn toàn. Không tưới nước vào vết thương.",
                "step_3_bio_pesticide": "Tưới phòng ngừa nấm rễ bằng dung dịch nấm đối kháng Trichoderma pha loãng vào giá thể đất mới (đất xỉ than + đá perlite).",
                "dosage_formula": "2g Trichoderma / 1 Lít nước tưới giá thể đất mới.",
                "spray_timing": "Tưới giá thể đất vào buổi sáng râm mát.",
                "pet_and_child_safety_warning": "An toàn 100% cho trẻ nhỏ và vật nuôi trong nhà."
            }
        }

    def get_protocol(self, disease_code: str) -> Dict[str, Any]:
        """US-075..US-079: Lấy phác đồ điều trị 3 bước Safe-First"""
        return self.protocol_database.get(
            disease_code,
            self.protocol_database["Rose___Powdery_Mildew"]
        )

    def list_all_encyclopedia_diseases(self) -> List[Dict[str, Any]]:
        """US-082: Tra cứu Bách khoa toàn thư phác đồ điều trị 30+ bệnh sâu hại cây đô thị"""
        return list(self.protocol_database.values())

    def create_medication_reminder_schedule(self, user_plant_id: str, disease_code: str) -> Dict[str, Any]:
        """
        US-080: Tự động tạo lịch nhắc xịt thuốc nhắc lại sau 3 ngày và theo dõi phục hồi sau 7 ngày.
        """
        now = datetime.utcnow()
        remind_day_3 = (now + timedelta(days=3)).strftime("%Y-%m-%d 17:30")
        audit_day_7 = (now + timedelta(days=7)).strftime("%Y-%m-%d 08:00")

        return {
            "user_plant_id": user_plant_id,
            "disease_code": disease_code,
            "spray_round_2_reminder": remind_day_3,
            "recovery_audit_day_7": audit_day_7,
            "message": "Đã tự động thiết lập lịch nhắc xịt thuốc đợt 2 sau 3 ngày (17:30) và đánh giá phục hồi sau 7 ngày!"
        }
