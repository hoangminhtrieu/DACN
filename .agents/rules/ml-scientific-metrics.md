---
trigger: always_on
---

---
trigger: glob
globs: ["**/*.py", "**/*.ipynb", "ai_service/**"]
description: Quy chuẩn đánh giá mô hình học máy, chống Data Leakage và xuất chỉ số F1-Score, Confusion Matrix
---

# Quy chuẩn Huấn luyện & Đánh giá Khoa học (ML Rigor)

1. **Chống rò rỉ dữ liệu (Zero Data Leakage):**
   - Tuyệt đối thực hiện chia tập `Train (80%)` và `Test (20%)` TRƯỚC KHI áp dụng Data Augmentation.
   - Tập ảnh chụp thực tế tại vườn ươm (`data/real_world_nursery_test/`) chỉ được dùng để đánh giá độc lập (External Validation), cấm trộn vào tập Train dưới mọi hình thức.
2. **Báo cáo chỉ số bắt buộc:**
   - Không bao giờ chỉ in ra `Accuracy` tổng. Mọi script đánh giá phải xuất đầy đủ: `Precision`, `Recall`, `F1-Score` (Macro và Weighted) cùng biểu đồ `Confusion Matrix` chuẩn hóa theo phần trăm.