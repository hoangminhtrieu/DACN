# Quy chuẩn Phòng ban Kỹ thuật Phần mềm (AI Engineering Department)

## 1. Nguyên tắc phối hợp liên bộ phận (Artifact-Driven Workflow)
- Không bao giờ viết code tính năng mới khi chưa có bản thiết kế kỹ thuật tại `docs/specs/[ten-tinh-nang]-spec.md`.
- Mọi sự bàn giao giữa Architect, Senior Dev, Code Reviewer và QA Tester đều phải cập nhật trạng thái trực tiếp vào file spec tương ứng.

## 2. Quy ước chất lượng cốt lõi
- Tuân thủ nguyên tắc SOLID, DRY và phân tách rõ ràng giữa các tầng (Controller/API, Service/Business Logic, Repository/Data Access).
- Mọi hàm xử lý nghiệp vụ đều phải có kiểm tra dữ liệu đầu vào (Validation) và bắt lỗi tường minh (Exception Handling).
- Không hardcode chuỗi kết nối, API key, hoặc cấu hình nhạy cảm trong source code.