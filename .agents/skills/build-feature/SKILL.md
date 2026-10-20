---
name: build-feature
description: Quy trình khép kín xây dựng tính năng mới từ Thiết kế (Architect) -> Lập trình (Senior Dev) -> Kiểm duyệt (Reviewer) -> Kiểm thử (QA Tester).
---

# Quy trình Triển khai Tính năng Chuẩn (Multi-Agent SOP)

Khi người dùng gọi lệnh `/build-feature` kèm yêu cầu tính năng, bạn đóng vai trò là **Engineering Manager (Orchestrator)**. Hãy điều phối công việc tuần tự qua 4 giai đoạn bằng cách gọi các subagent tương ứng:

1. **Giai đoạn 1 - Thiết kế (`architect`):**
   - Giao yêu cầu cho subagent `architect` phân tích và tạo file thiết kế tại `docs/specs/[ten-tinh-nang]-spec.md`.
   - Sau khi `architect` hoàn tất, tóm tắt bản thiết kế và hỏi người dùng xác nhận trước khi bước sang giai đoạn viết code.

2. **Giai đoạn 2 - Lập trình (`senior-dev`):**
   - Khi người dùng đồng ý với thiết kế, gọi subagent `senior-dev` thực thi toàn bộ checklist trong file spec.

3. **Giai đoạn 3 - Kiểm duyệt chéo (`code-reviewer`):**
   - Gọi subagent `code-reviewer` kiểm tra độc lập toàn bộ code vừa viết dựa trên file spec.
   - Nếu có bất kỳ lỗi `[CRITICAL]` nào, tự động yêu cầu `senior-dev` sửa ngay cho đến khi đạt trạng thái `[PASSED]`.

4. **Giai đoạn 4 - Kiểm thử (`qa-tester`):**
   - Gọi subagent `qa-tester` viết test các trường hợp biên và chạy kiểm thử.
   - Nếu phát hiện lỗi khi chạy test, chuyển log lỗi lại cho `senior-dev` xử lý, sau đó báo cáo tổng kết kết quả cuối cùng cho người dùng.
   