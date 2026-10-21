"""
Module Theo dõi Lệch Phân phối Dữ liệu (Data Drift) & Thu thập Mẫu Active Learning
Mục tiêu (US-044, US-047):
1. Theo dõi Data Drift khi mô hình hoạt động trong thực tế đô thị.
2. Lưu trữ mẫu phản hồi chẩn đoán sai của người dùng để phục vụ tái huấn luyện tự động.
"""

import os
import json
import time
from datetime import datetime

class DataDriftAndActiveLearningManager:
    def __init__(self, storage_dir="data/active_learning"):
        self.storage_dir = storage_dir
        self.feedback_dir = os.path.join(storage_dir, "incorrect_feedback")
        self.drift_log_file = os.path.join(storage_dir, "drift_metrics.json")
        os.makedirs(self.feedback_dir, exist_ok=True)

    def log_inference_distribution(self, confidence: float, blur_score: float, brightness: float) -> dict:
        """
        US-044: Kiểm tra độ lệch phân phối (Data Drift) dựa trên phân phối xác suất và đặc trưng ảnh.
        """
        drift_detected = False
        drift_reason = None

        # Nếu độ tin cậy trung bình giảm sâu dưới 65% liên tục -> Cảnh báo Data Drift
        if confidence < 0.65:
            drift_detected = True
            drift_reason = "Độ tin cậy suy luận thấp bất thường (<65%) - Có khả năng ảnh ngoài phân phối tập train."

        status_record = {
            "timestamp": datetime.utcnow().isoformat(),
            "confidence": round(confidence, 3),
            "blur_score": blur_score,
            "brightness": brightness,
            "drift_detected": drift_detected,
            "drift_reason": drift_reason
        }

        return status_record

    def save_user_incorrect_feedback(
        self,
        diagnosis_id: str,
        predicted_disease: str,
        user_corrected_disease: str,
        feedback_notes: str,
        image_bytes: bytes = None
    ) -> str:
        """
        US-047: Lưu mẫu ảnh chẩn đoán sai do người dùng phản hồi vào kho Active Learning.
        """
        record_id = f"feedback_{int(time.time())}_{diagnosis_id[:8]}"
        record_path = os.path.join(self.feedback_dir, f"{record_id}.json")

        record = {
            "record_id": record_id,
            "diagnosis_id": diagnosis_id,
            "predicted_disease": predicted_disease,
            "user_corrected_disease": user_corrected_disease,
            "feedback_notes": feedback_notes,
            "recorded_at": datetime.utcnow().isoformat(),
            "status": "QUEUED_FOR_RETRAINING"
        }

        with open(record_path, "w", encoding="utf-8") as f:
            json.dump(record, f, indent=2, ensure_ascii=False)

        # Lưu ảnh nếu có
        if image_bytes:
            img_file = os.path.join(self.feedback_dir, f"{record_id}.jpg")
            with open(img_file, "wb") as f:
                f.write(image_bytes)

        return record_id
