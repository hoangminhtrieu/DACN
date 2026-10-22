import unittest
import sys
import os

# Thêm path app vào sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.services.differential_diagnosis_service import DifferentialDiagnosisService
from app.services.safe_first_protocol_service import SafeFirstProtocolService
from app.services.voice_assistant_service import VietnameseVoiceAssistantService

class TestDay4DifferentialAndVoice(unittest.TestCase):

    def setUp(self):
        self.diff_svc = DifferentialDiagnosisService()
        self.safe_svc = SafeFirstProtocolService()
        self.voice_svc = VietnameseVoiceAssistantService()

    def test_us_058_060_verification_questions(self):
        """US-058 - US-060: Bảng câu hỏi xác thực triệu chứng vật lý kèm ảnh minh họa"""
        questions = self.diff_svc.get_questions_for_disease("Rose___Powdery_Mildew")
        self.assertGreaterEqual(len(questions), 3)
        self.assertIsNotNone(questions[0]["sample_illustration_url"])
        self.assertIn("lau sạch", questions[0]["question_text"].lower())

    def test_us_061_recalculate_confidence_positive(self):
        """US-061: Thuật toán tái tính toán độ tin cậy khi người dùng xác nhận đúng triệu chứng nấm"""
        result = self.diff_svc.recalculate_confidence(
            primary_disease_code="Rose___Powdery_Mildew",
            initial_confidence=0.80,
            answers={
                "q_powder_wipe": True,
                "q_spider_web": False,
                "q_leaf_curl": True
            }
        )
        self.assertGreater(result["final_confidence"], 0.80)
        self.assertEqual(result["pathogen_type"], "FUNGUS")
        self.assertEqual(result["spread_risk"], "HIGH")

    def test_us_062_spider_mite_branch(self):
        """US-062: Nhánh phân biệt Bệnh Nấm vs Nhện Đỏ Chích Hút"""
        result = self.diff_svc.recalculate_confidence(
            primary_disease_code="Rose___Powdery_Mildew",
            initial_confidence=0.75,
            answers={
                "q_spider_web": True,
                "q_powder_wipe": False
            }
        )
        self.assertTrue(result["is_diverted_to_pest"])
        self.assertEqual(result["pathogen_type"], "INSECT_PEST")
        self.assertIn("Nhện Đỏ", result["final_disease_name_vi"])

    def test_us_063_nutrient_deficiency_branch(self):
        """US-063: Phân biệt Nấm vs Thiếu Sắt Vi Lượng (Iron Chlorosis)"""
        result = self.diff_svc.recalculate_confidence(
            primary_disease_code="Rose___Powdery_Mildew",
            initial_confidence=0.70,
            answers={
                "q_vein_green": True,
                "q_powder_wipe": False
            }
        )
        self.assertTrue(result["is_diverted_to_deficiency"])
        self.assertEqual(result["pathogen_type"], "NUTRIENT_DEFICIENCY")
        self.assertEqual(result["spread_risk"], "NONE")

    def test_us_067_070_voice_command_parsing(self):
        """US-067 - US-070: Nhận diện giọng nói tiếng Việt và thực thi khẩu lệnh rảnh tay"""
        res1 = self.voice_svc.process_voice_command("mở camera quét bệnh cho cây hoa hồng")
        self.assertEqual(res1["detected_intent"], "OPEN_SCANNER")
        self.assertEqual(res1["action_payload"]["navigate_to"], "CAMERA_SCANNER")

        res2 = self.voice_svc.process_voice_command("tôi đã tưới nước cho cây rồi")
        self.assertEqual(res2["detected_intent"], "ACTION_COMPLETE_WATERING")
        self.assertEqual(res2["action_payload"]["action"], "COMPLETE")

    def test_us_075_079_safe_first_3_steps(self):
        """US-075 - US-079: Phác đồ Safe-First 3 bước và an toàn thú cưng/trẻ em"""
        protocol = self.safe_svc.get_protocol("Rose___Powdery_Mildew")
        self.assertIn("step_1_isolation_pruning", protocol)
        self.assertIn("step_2_organic_home_remedy", protocol)
        self.assertIn("step_3_bio_pesticide", protocol)

        # Kiểm tra hoạt chất sinh học an toàn: Bacillus subtilis hoặc Trichoderma
        bio_text = protocol["step_3_bio_pesticide"]
        self.assertTrue("Bacillus subtilis" in bio_text or "Trichoderma" in bio_text)

        # Kiểm tra cảnh báo an toàn thú cưng
        self.assertIn("AN TOÀN CHO TRẺ EM VÀ CHÓ MÈO", protocol["pet_and_child_safety_warning"])

    def test_us_080_082_reminder_and_encyclopedia(self):
        """US-080 - US-082: Lịch nhắc xịt thuốc và bách khoa sâu bệnh"""
        reminder = self.safe_svc.create_medication_reminder_schedule("plant_rose_01", "Rose___Powdery_Mildew")
        self.assertIn("spray_round_2_reminder", reminder)
        self.assertIn("recovery_audit_day_7", reminder)

        encyclopedia = self.safe_svc.list_all_encyclopedia_diseases()
        self.assertGreaterEqual(len(encyclopedia), 3)

if __name__ == "__main__":
    unittest.main()
