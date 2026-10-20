---
name: train-and-audit-model
description: Huấn luyện MobileNetV3/YOLO-Nano, vẽ Confusion Matrix và lập báo cáo phân tích lỗi nhầm lẫn giữa các bệnh.
---

Khi được gọi, điều phối `ml-engineer` thực hiện:
1. Huấn luyện mô hình phân loại/nhận diện trên tập `train` và đánh giá độc lập trên cả 2 tập: `test` (PlantVillage/Kaggle) và `real_world_validation` (ảnh chụp thực tế tại vườn ươm).
2. Xuất bảng chỉ số `Precision`, `Recall`, `F1-Score` của từng nhóm bệnh và lưu biểu đồ `confusion_matrix.png` độ phân giải cao vào `docs/evaluation-reports/`.
3. Phân tích tự động từ Confusion Matrix: chỉ ra nhóm bệnh nào đạt độ chính xác cao nhất (ví dụ: Phấn trắng) và cặp bệnh nào hay bị nhầm lẫn nhất (ví dụ: Đốm lá vi khuẩn vs. Đốm lá do nấm), giải thích nguyên nhân thị giác và đề xuất bộ câu hỏi kiểm chứng chéo để bù đắp.