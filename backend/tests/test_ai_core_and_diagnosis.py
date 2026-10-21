import io
import pytest
import pytest_asyncio
from PIL import Image
from httpx import AsyncClient, ASGITransport
from app.main import app
from ai_service.train_mobilenetv3 import generate_scientific_training_report
from ai_service.quantize_tflite import export_and_audit_quantized_model
from ai_service.image_preprocessor import ImageQualityAuditor

def create_dummy_leaf_image(color=(34, 139, 34), size=(224, 224)):
    """Tạo ảnh lá cây hợp lệ"""
    img = Image.new("RGB", size, color)
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()

def create_blurry_black_image(size=(224, 224)):
    """Tạo ảnh đen xì / mờ nét không phải lá cây"""
    img = Image.new("RGB", size, (10, 10, 10))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()

def test_ml_scientific_training_metrics_us_037_to_040():
    """US-037..US-040: Kiểm tra chỉ số khoa học F1-Score và Confusion Matrix"""
    summary, cm_path = generate_scientific_training_report(output_dir="reports/test_audit")
    assert summary["metrics"]["macro_avg"]["f1_score"] >= 0.85
    assert summary["metrics"]["weighted_avg"]["f1_score"] >= 0.85
    assert cm_path.endswith(".png")

def test_tflite_quantization_and_latency_us_041_043():
    """US-041, US-043: Kiểm tra nén mô hình <15MB và độ trễ <200ms"""
    benchmark = export_and_audit_quantized_model(output_dir="mobile_app/assets/models")
    assert benchmark["file_size_mb"] < 15.0
    assert benchmark["is_size_compliant"] is True
    assert benchmark["average_inference_latency_ms"] < 200.0
    assert benchmark["is_latency_compliant"] is True

def test_image_quality_auditor_us_050():
    """US-050: Phát hiện cảnh báo ảnh mờ, tối hoặc không phải lá"""
    bad_img = create_blurry_black_image()
    audit = ImageQualityAuditor.audit_image_quality(bad_img)
    assert audit["is_valid_for_inference"] is False
    assert len(audit["issues"]) > 0

@pytest.mark.asyncio
async def test_diagnosis_predict_and_gradcam_us_051_to_054():
    """US-051..US-054: API chẩn đoán bệnh trả tên bệnh, Grad-CAM heatmap và mức độ nghiêm trọng"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        good_img = create_dummy_leaf_image()
        files = {"file": ("leaf.jpg", good_img, "image/jpeg")}

        res = await ac.post("/api/v1/diagnosis/predict", files=files)
        assert res.status_code == 200
        data = res.json()
        assert data["is_quality_valid"] is True
        assert "Bệnh Phấn Trắng" in data["primary_prediction"]["disease_name_vi"]
        assert data["primary_prediction"]["severity"] in ["LOW", "MEDIUM", "CRITICAL"]
        assert "data:image/jpeg;base64," in data["gradcam_heatmap_url"]
        assert len(data["explanation_text"]) > 10

@pytest.mark.asyncio
async def test_active_learning_feedback_us_047_057():
    """US-047, US-057: Phản hồi kết quả chưa đúng lưu vào Active Learning"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        feedback_payload = {
            "diagnosis_id": "diag-12345",
            "predicted_disease": "Bệnh Phấn Trắng",
            "user_corrected_disease": "Dư lượng vôi đọng nước",
            "feedback_notes": "Lau bằng tay sạch ngay, không phải nấm nốt"
        }
        res = await ac.post("/api/v1/diagnosis/feedback", json=feedback_payload)
        assert res.status_code == 200
        assert res.json()["status"] == "success"
        assert "feedback_id" in res.json()
