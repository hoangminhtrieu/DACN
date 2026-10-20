---
name: daily-report
description: Tổng hợp toàn bộ công việc các Agent đã làm được trong ngày, đối chiếu với Product Backlog và xuất Báo cáo Tiến độ Cuối ngày.
---

# Quy trình Xuất Báo Cáo Tiến Độ Cuối Ngày (End-of-Day Standup Report)

Khi người dùng gõ lệnh `/daily-report` vào cuối ngày, bạn đóng vai trò là **Scrum Master / Project Manager**. Hãy thực hiện tuần tự các bước sau:

1. **Quét dữ liệu thực tế trong dự án:**
   - Đọc file log trong ngày tại `docs/daily-logs/` kết hợp chạy lệnh `git status` và `git log --since="midnight"` để kiểm chứng chính xác những file code, tài liệu hoặc model nào đã thực sự được tạo/chỉnh sửa hôm nay.
   - Đối chiếu với bảng `docs/BACKLOG_TRACKER.md`.

2. **Xuất Báo cáo Tiến độ Cuối ngày cho người dùng theo đúng mẫu sau:**

### 📊 BÁO CÁO TIẾN ĐỘ CUỐI NGÀY — DỰ ÁN URBAN PLANTS
- **Ngày báo cáo:** [Ngày/Tháng/Năm] | **Tuần thứ:** [X/6]
- **Tổng tiến độ toàn dự án:** [Số US đã HOÀN THÀNH] / 100 User Stories ([X]%)

#### 1. Các hạng mục đã HOÀN THÀNH trong hôm nay:
| Mã US | Nội dung công việc | Agent thực hiện | File / Minh chứng hoàn thành | Trạng thái mới |
| :--- | :--- | :--- | :--- | :--- |
| `US-xxx` | ... | `@...` | `đường/dẫn/file` | **HOÀN THÀNH** |

#### 2. Các hạng mục ĐANG THỰC HIỆN dở dang (Chuyển sang ngày mai):
- `US-xxx` ([Tên Agent] - Đạt [X]%): Nêu rõ phần nào đã xong, phần nào còn lại.

#### 3. Kết quả Kiểm duyệt & Kiểm thử (`@code-reviewer` & `@qa-tester`):
- Số lỗi phát hiện và đã xử lý trong ngày: ...
- Các chỉ số kỹ thuật đo được hôm nay (F1-Score, độ trễ ms, dung lượng MB... nếu có): ...

#### 4. Kế hoạch ưu tiên cho ngày mai:
- Đề xuất 3-4 mã `US-xxx` tiếp theo cần giao cho từng Agent vào sáng mai.
