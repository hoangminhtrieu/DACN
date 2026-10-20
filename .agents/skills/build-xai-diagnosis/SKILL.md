---
name: build-xai-diagnosis
description: Xây dựng trọn gói luồng Chẩn đoán AI kèm bản đồ nhiệt Grad-CAM, Bảng câu hỏi phân biệt và Phác đồ Safe-First 3 bước.
---

Khi được gọi, điều phối các subagent theo đúng 4 bước:
1. **`architect`:** Thiết kế API Contract và Database Schema lưu trữ: Thông tin bệnh, Bộ 3 câu hỏi kiểm chứng chéo (kèm trọng số cộng/trừ điểm xác suất), và Phác đồ 3 bước Safe-First tại `docs/specs/xai-diagnosis-spec.md`.
2. **`ml-engineer`:** Viết hàm trích xuất bản đồ nhiệt **Grad-CAM** phủ lên ảnh gốc (tô vùng đỏ/vàng tại vị trí lá bệnh) và trả về qua API Python (FastAPI/Flask) cùng Top 3 xác suất bệnh.
3. **`senior-dev`:** Xây dựng giao diện và logic kết hợp xác suất AI với câu trả lời Yes/No của người dùng để chốt kết quả cuối cùng, sau đó hiển thị phác đồ điều trị 3 bước.
4. **`code-reviewer` & `qa-tester`:** Kiểm tra tốc độ phản hồi ảnh Grad-CAM và viết Unit Test kiểm chứng công thức tính lại xác suất sau khi người dùng trả lời câu hỏi.