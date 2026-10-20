---
trigger: always_on
description: Quy tắc bảo mật và kiểm soát thay đổi file trong dự án
---

- Không bao giờ xóa hoặc ghi đè các cấu hình môi trường (`.env`, `appsettings.json`) mà không hỏi ý kiến người dùng.
- Khi sửa code, chỉ áp dụng các khối thay đổi tối thiểu (minimal diffs), không tự ý format lại toàn bộ các dòng code không liên quan.
- Mọi thay đổi liên quan đến cấu trúc bảng Database phải đi kèm script hoặc migration rõ ràng.