import uuid
from typing import Optional, List
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status, Depends
from pydantic import BaseModel

from ai_service.image_preprocessor import ImageQualityAuditor
from ai_service.gradcam_engine import GradCAMEngine
from ai_service.data_drift_detector import DataDriftAndActiveLearningManager
from app.api.deps import get_current_active_user
from app.models.user import User

router = APIRouter(prefix="/diagnosis", tags=["AI Plant Disease Diagnosis & Grad-CAM"])

class DifferentialDiseaseItem(BaseModel):
    disease_name_vi: str
    scientific_name: str
    confidence: float
    severity: str

class DiagnosisPredictionResponse(BaseModel):
    diagnosis_id: str
    primary_prediction: DifferentialDiseaseItem
    differential_candidates: List[DifferentialDiseaseItem]
    gradcam_heatmap_url: str
    explanation_text: str
    is_quality_valid: bool
    quality_warnings: List[str]
    drift_status: dict

class FeedbackRequest(BaseModel):
    diagnosis_id: str
    predicted_disease: str
    user_corrected_disease: str
    feedback_notes: str

@router.post("/predict", response_model=DiagnosisPredictionResponse)
async def predict_plant_disease(
    file: UploadFile = File(...),
    plant_id: Optional[str] = Form(None),
    current_user: Optional[User] = Depends(get_current_active_user)
):
    """
    US-048, US-049: Quét trực tiếp hoặc tải ảnh từ thư viện.
    US-050: Kiểm tra độ mờ, rung lắc, thiếu sáng hoặc không phải lá.
    US-051, US-054: Trả kết quả tên bệnh, tỷ lệ tin cậy và mức độ nghiêm trọng.
    US-052, US-053: Bản đồ nhiệt Grad-CAM hỗ trợ thanh trượt Opacity.
    US-044: Kiểm tra độ lệch phân phối dữ liệu (Data Drift).
    """
    image_bytes = await file.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Tệp ảnh không hợp lệ.")

    # 1. US-050: Kiểm định chất lượng ảnh
    quality_audit = ImageQualityAuditor.audit_image_quality(image_bytes)
    if not quality_audit["is_valid_for_inference"]:
        return DiagnosisPredictionResponse(
            diagnosis_id=str(uuid.uuid4()),
            primary_prediction=DifferentialDiseaseItem(
                disease_name_vi="Không thể xác định (Ảnh chưa đạt chuẩn)",
                scientific_name="Unknown",
                confidence=0.0,
                severity="NONE"
            ),
            differential_candidates=[],
            gradcam_heatmap_url="",
            explanation_text="Vui lòng chụp lại ảnh theo hướng dẫn lấy nét để AI nhận diện chuẩn xác.",
            is_quality_valid=False,
            quality_warnings=quality_audit["issues"],
            drift_status={"drift_detected": False}
        )

    # 2. US-046: Tách nền lá cây
    segmented_bytes = ImageQualityAuditor.remove_background_and_segment(image_bytes)

    # 3. US-039, US-051, US-054: Phân loại bệnh (Mô phỏng MobileNetV3 Transfer Learning)
    primary = DifferentialDiseaseItem(
        disease_name_vi="Bệnh Phấn Trắng (Powdery Mildew)",
        scientific_name="Podosphaera pannosa",
        confidence=0.885,
        severity="MEDIUM"
    )

    differential = [
        DifferentialDiseaseItem(
            disease_name_vi="Bệnh Mốc Xám (Botrytis Blight)",
            scientific_name="Botrytis cinerea",
            confidence=0.182,
            severity="MEDIUM"
        ),
        DifferentialDiseaseItem(
            disease_name_vi="Dư lượng vôi khoáng đọng nước",
            scientific_name="Mineral Deposit",
            confidence=0.063,
            severity="LOW"
        )
    ]

    # 4. US-052: Sinh ảnh nhiệt Grad-CAM Heatmap
    gradcam_engine = GradCAMEngine()
    gradcam_result = gradcam_engine.generate_heatmap_and_explanation(
        image_bytes=image_bytes,
        predicted_class="Rose___Powdery_Mildew"
    )

    # 5. US-044: Ghi nhận Data Drift metrics
    drift_mgr = DataDriftAndActiveLearningManager()
    drift_status = drift_mgr.log_inference_distribution(
        confidence=primary.confidence,
        blur_score=quality_audit["blur_score"],
        brightness=quality_audit["brightness_score"]
    )

    return DiagnosisPredictionResponse(
        diagnosis_id=str(uuid.uuid4()),
        primary_prediction=primary,
        differential_candidates=differential,
        gradcam_heatmap_url=gradcam_result["heatmap_data_url"],
        explanation_text=gradcam_result["explanation_text"],
        is_quality_valid=True,
        quality_warnings=[],
        drift_status=drift_status
    )

@router.post("/feedback")
async def submit_incorrect_diagnosis_feedback(
    req: FeedbackRequest,
    current_user: Optional[User] = Depends(get_current_active_user)
):
    """
    US-047, US-057: Tiếp nhận phản hồi 'Kết quả chưa đúng' và lưu vào kho Active Learning.
    """
    drift_mgr = DataDriftAndActiveLearningManager()
    feedback_id = drift_mgr.save_user_incorrect_feedback(
        diagnosis_id=req.diagnosis_id,
        predicted_disease=req.predicted_disease,
        user_corrected_disease=req.user_corrected_disease,
        feedback_notes=req.feedback_notes
    )
    return {
        "status": "success",
        "feedback_id": feedback_id,
        "message": "Cảm ơn bạn! Mẫu ảnh đã được đưa vào kho Active Learning để tái huấn luyện mô hình AI."
    }
