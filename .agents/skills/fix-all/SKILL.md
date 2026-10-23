---
name: fix-all
description: Quét toàn bộ ứng dụng tìm lỗi giao diện, nút chết, lỗi logic, lỗi Console và tự động sửa sạch 100%.
---

# Quy trình Quét & Tự động Sửa lỗi Toàn diện (Full Audit & Auto-Fix)

Khi người dùng gõ `/fix-all`:
1. Điều phối `@qa-tester` và `@code-reviewer` quét toàn bộ source code và giao diện để tìm:
   - Lỗi tràn khung, vỡ layout, scrollbar thô, ảnh lỗi 404 hoặc sai chủ đề cây trồng.
   - Các nút bấm chưa có sự kiện (`Dead Buttons`) hoặc tính năng chỉ mới làm vỏ bọc tĩnh.
   - Lỗi không đồng bộ dữ liệu (State/LocalStorage/API) giữa các tab và lỗi trong Console/Terminal.
2. Ghi danh sách lỗi phát hiện được vào `docs/AUDIT_BUG_REPORT.md`.
3. Giao cho `@senior-dev` và `@ml-engineer` tự động sửa triệt để 100% các lỗi trong danh sách mà không cần chờ người dùng nhắc từng bước.
4. Kiểm tra lại lần cuối, cập nhật trạng thái `[x] ĐÃ FIX` vào `docs/AUDIT_BUG_REPORT.md` và báo cáo ngắn gọn danh sách các lỗi đã khắc phục.
