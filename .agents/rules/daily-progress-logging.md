---
trigger: always_on
---

---
trigger: always_on
description: Quy tắc bắt buộc cập nhật trạng thái Product Backlog và ghi log công việc phục vụ báo cáo cuối ngày
---

# Quy chuẩn Ghi nhận Tiến độ Theo Ngày (Daily Backlog Tracking)

1. **Mọi tác vụ đều phải gắn mã User Story (`US-xxx`):**
   - Trước và sau khi thực hiện bất kỳ thay đổi code, thiết kế hay huấn luyện mô hình nào, Agent bắt buộc phải đối chiếu với mã `US-003` đến `US-100` trong `docs/BACKLOG_TRACKER.md`.
2. **Tự động ghi nhật ký khi hoàn thành việc:**
   - Ngay khi hoàn tất một hạng mục (hoặc một phần của hạng mục), Agent phụ trách phải tự động ghi thêm 1 dòng vào file `docs/daily-logs/YYYY-MM-DD.md` theo đúng cấu trúc:
     `- [Giờ hoàn thành] | [Tên Agent] | [Mã US-xxx] | [Trạng thái: HOÀN THÀNH / ĐANG LÀM (x%)] | [Danh sách file đã tạo/sửa & Kết quả đạt được]`