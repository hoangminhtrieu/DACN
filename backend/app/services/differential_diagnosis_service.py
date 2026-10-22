from typing import List, Dict, Any
from app.models.treatment import PathogenCategory, SpreadRisk

class DifferentialDiagnosisService:
    def __init__(self):
        # Bộ câu hỏi kiểm chứng chuẩn hóa theo từng loại bệnh đô thị
        self.question_bank = {
            "Rose___Powdery_Mildew": [
                {
                    "question_id": "q_powder_wipe",
                    "question_text": "Lớp bụi màu trắng bạc trên bề mặt lá có thể dùng ngón tay lau sạch dễ dàng không?",
                    "sample_illustration_url": "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae",
                    "target": "Phân biệt Nấm phấn trắng vs Cặn canxi nước tưới"
                },
                {
                    "question_id": "q_spider_web",
                    "question_text": "Mặt dưới của phiến lá có xuất hiện mạng tơ li ti hoặc con bọ nhỏ xíu màu đỏ/vàng bò chậm không?",
                    "sample_illustration_url": "https://images.unsplash.com/photo-1533038590840-1cde6e668a91",
                    "target": "Phân biệt Nấm bệnh vs Nhện đỏ chích hút (US-062)"
                },
                {
                    "question_id": "q_leaf_curl",
                    "question_text": "Lá non mới nhú có hiện tượng bị cong queo, mép lá khô giòn và nụ hoa bị teo tóp không?",
                    "sample_illustration_url": "https://images.unsplash.com/photo-1518709268805-4e9042af9f23",
                    "target": "Xác nhận mức độ nấm phấn trắng xâm nhập sâu vào mô lá"
                }
            ],
            "General___Iron_Deficiency_Chlorosis": [
                {
                    "question_id": "q_vein_green",
                    "question_text": "Phiến lá non chuyển sang màu vàng nhạt nhưng các đường gân lá vẫn giữ màu xanh đậm rõ nét?",
                    "sample_illustration_url": "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                    "target": "Phân biệt Bệnh truyền nhiễm vs Thiếu vi chất Sắt (US-063)"
                }
            ]
        }

    def get_questions_for_disease(self, disease_code: str) -> List[Dict[str, Any]]:
        """US-059, US-060: Lấy danh sách câu hỏi kiểm chứng kèm ảnh mẫu minh họa"""
        return self.question_bank.get(disease_code, self.question_bank["Rose___Powdery_Mildew"])

    def recalculate_confidence(
        self,
        primary_disease_code: str,
        initial_confidence: float,
        answers: Dict[str, bool]
    ) -> Dict[str, Any]:
        """
        US-061: Thuật toán tái tính toán lại độ tin cậy dựa trên bảng câu hỏi kiểm chứng chéo.
        US-062: Tách biệt Nấm bệnh vs Côn trùng chích hút.
        US-063: Tách biệt Bệnh truyền nhiễm vs Thiếu vi chất.
        US-064: Khuyến cáo nguy cơ lây lan trong không gian ban công.
        """
        final_confidence = initial_confidence
        final_disease = "Bệnh Phấn Trắng (Powdery Mildew)"
        scientific_name = "Podosphaera pannosa"
        pathogen_type = PathogenCategory.FUNGUS
        spread_risk = SpreadRisk.HIGH
        spread_warning = "Nguy cơ lây lan RẤT CAO trong phạm vi 1.5 - 2m qua gió ban công! Cần cách ly chậu ngay lập tức."
        incubation_period = "3 - 5 ngày ở nhiệt độ 22 - 28°C"

        # US-062: Kiểm tra nếu có tơ nhện li ti -> phát hiện nhện đỏ
        if answers.get("q_spider_web") is True:
            final_disease = "Tổn thương do Nhện Đỏ Chích Hút (Spider Mites)"
            scientific_name = "Tetranychus urticae"
            pathogen_type = PathogenCategory.INSECT_PEST
            final_confidence = 0.945
            spread_risk = SpreadRisk.HIGH
            spread_warning = "Nhện đỏ phát tán cực nhanh trong thời tiết khô nóng! Tránh dùng thuốc diệt nấm, cần dùng dầu Neem hoặc xịt nước rửa trôi."
            return {
                "final_disease_name_vi": final_disease,
                "scientific_name": scientific_name,
                "pathogen_type": pathogen_type.value,
                "final_confidence": round(final_confidence, 3),
                "is_diverted_to_pest": True,
                "spread_risk": spread_risk.value,
                "spread_warning": spread_warning,
                "incubation_period": "Vòng đời nhện đỏ: 8 - 12 ngày từ trứng đến trưởng thành"
            }

        # US-063: Kiểm tra nếu phiến vàng gân xanh -> phát hiện thiếu vi lượng
        if answers.get("q_vein_green") is True:
            final_disease = "Hiện Tượng Thiếu Vi Lượng Sắt (Iron Deficiency Chlorosis)"
            scientific_name = "Nutrient Deficiency"
            pathogen_type = PathogenCategory.NUTRIENT_DEFICIENCY
            final_confidence = 0.960
            spread_risk = SpreadRisk.NONE
            spread_warning = "Hiện tượng phi sinh học, KHÔNG lây lan sang các cây lân cận. Tuyệt đối không xịt thuốc BVTV, chỉ cần bổ sung chelate sắt Fe-EDDHA."
            return {
                "final_disease_name_vi": final_disease,
                "scientific_name": scientific_name,
                "pathogen_type": pathogen_type.value,
                "final_confidence": round(final_confidence, 3),
                "is_diverted_to_deficiency": True,
                "spread_risk": spread_risk.value,
                "spread_warning": spread_warning,
                "incubation_period": "Không có vòng đời lây nhiễm"
            }

        # Kiểm tra lớp phấn trắng lau sạch được
        if answers.get("q_powder_wipe") is True:
            final_confidence += 0.12 # Bột nấm phấn trắng lau bay dễ
        else:
            final_confidence -= 0.18 # Nếu dính chặt vào mô lá -> có thể là cặn vôi hoặc mốc xám

        if answers.get("q_leaf_curl") is True:
            final_confidence += 0.08

        # Giới hạn trong khoảng [0.05, 0.98]
        final_confidence = min(max(final_confidence, 0.05), 0.98)

        return {
            "final_disease_name_vi": final_disease,
            "scientific_name": scientific_name,
            "pathogen_type": pathogen_type.value,
            "final_confidence": round(final_confidence, 3),
            "is_diverted_to_pest": False,
            "spread_risk": spread_risk.value,
            "spread_warning": spread_warning,
            "incubation_period": incubation_period
        }
