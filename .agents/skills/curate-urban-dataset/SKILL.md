---
name: curate-urban-dataset
description: Lọc bộ dữ liệu PlantVillage và Kaggle theo nhóm cây cảnh đô thị, chia tỷ lệ 80/20 và tạo khung lưu trữ tập ảnh thực tế.
---

Khi được gọi, hãy giao cho `ml-engineer` thực hiện tuần tự:
1. Tạo cấu trúc thư mục dữ liệu gồm: `data/raw/`, `data/processed/train` (80%), `data/processed/test` (20%), và `data/real_world_validation/` (dành cho ảnh chụp thực tế tại đường Thành Thái, Q.12).
2. Viết script Python lọc và gom nhóm các lớp bệnh phổ biến ở cây trồng ban công (Cà chua bi, Ớt, Hoa hồng, Sen đá/Kiểng lá) gồm: Bệnh phấn trắng (Powdery Mildew), Đốm lá do nấm (Fungal Leaf Spot), Đốm lá vi khuẩn (Bacterial Spot), Cháy lá/Mốc sương (Late/Early Blight), Vàng lá thiếu vi chất/nhện đỏ, và Lá khỏe mạnh (Healthy).
3. Kiểm tra cân bằng dữ liệu (Class Balance) và xuất bảng thống kê số lượng ảnh mỗi lớp ra `docs/evaluation-reports/dataset-summary.md`.