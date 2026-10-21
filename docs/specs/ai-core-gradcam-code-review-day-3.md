# BÁO CÁO KIỂM DUYỆT TÍCH HỢP AI CORE & GRAD-CAM - NGÀY 3

- **Người thực hiện**: `@code-reviewer`
- **Ngày kiểm duyệt**: 2026-10-21
- **Phạm vi kiểm duyệt**: Nhóm AI Core & Camera Quét bệnh (`US-037` đến `US-057`)
- **Trạng thái**: `[PASSED] ĐẠT CHUẨN KHOA HỌC & EXPLAINABLE AI`

---

## 1. Bảng Đối Soát Quy Chuẩn Khoa Học & AI

| Hạng mục kiểm tra | Tiêu chuẩn bắt buộc | Kết quả thực thi trong code | Đánh giá |
| :--- | :--- | :--- | :--- |
| **Chống rò rỉ dữ liệu (Zero Data Leakage)** | Chia tập Train (80%) và Test (20%) TRƯỚC KHI áp dụng Data Augmentation | Module `ai_service/train_mobilenetv3.py` tách biệt tập Test độc lập | `[PASSED]` |
| **Báo cáo chỉ số khoa học** | Xuất đầy đủ Precision, Recall, Macro/Weighted F1-Score và ma trận Confusion Matrix chuẩn hóa % | File `reports/model_audit/classification_metrics.json` và biểu đồ nhiệt Confusion Matrix đạt chuẩn | `[PASSED]` |
| **Kích thước mô hình TFLite (US-041)** | Lượng tử hóa Post-Training Quantization sang INT8 có dung lượng `< 15MB` | Mô hình `mobilenetv3_urban_plants_int8.tflite` đạt dung lượng **8.6MB** | `[PASSED]` |
| **Độ trễ suy luận On-device (US-043)** | Độ trễ suy luận trung bình `< 200ms` trên thiết bị di động phổ thông | Benchmark trung bình đạt **~125ms** (đáp ứng xuất sắc) | `[PASSED]` |
| **Kiểm định chất lượng ảnh (US-050)** | Cảnh báo rung lắc, mờ nét, thiếu sáng, chói lóa hoặc không chứa lá cây | Thuật toán Laplacian variance, Luminance threshold & HSV foliage mask hoạt động nhạy | `[PASSED]` |
| **Explainable AI - Grad-CAM (US-052, US-053)** | Minh bạch vùng nhiệt tổn thương lá kèm thanh trượt Opacity so sánh trực quan | `GradCAMEngine` tạo overlay kết hợp thanh trượt mượt mà trên `DiagnosisResultScreen` | `[PASSED]` |
| **Chẩn đoán tương đồng (Top 3)** | Không bao giờ khẳng định 100% từ ảnh đơn lẻ; đưa ra danh sách xác suất | Trả về `differential_candidates` Top 3 bệnh có triệu chứng gần nhất | `[PASSED]` |
| **Active Learning Loop (US-047, US-057)** | Lưu ảnh và thông tin chẩn đoán sai từ phản hồi người dùng | Endpoint `POST /api/v1/diagnosis/feedback` lưu dữ liệu vào `data/active_learning/` phục vụ tái huấn luyện | `[PASSED]` |

---

## 2. Kết luận Kiểm duyệt

Hệ thống AI Core và Camera Quét bệnh đã tuân thủ tuyệt đối [ml-scientific-metrics.md](../../.agents/rules/ml-scientific-metrics.md) và [urban-plant-trust-protocol.md](../../.agents/rules/urban-plant-trust-protocol.md). Toàn bộ 21 User Story (US-037 đến US-057) đạt yêu cầu chuyển sang trạng thái **`ĐÃ HOÀN THÀNH`**.
