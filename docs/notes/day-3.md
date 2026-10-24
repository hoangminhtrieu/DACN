/sprint-daily Hôm nay là Ngày 3. Hãy tập trung triển khai nhóm AI Core & Camera Quét bệnh (US-037 đến US-057):
1. Phân công @ml-engineer và @senior-dev thực hiện:
   - Tiền xử lý dữ liệu, Data Augmentation, huấn luyện mô hình Transfer Learning cho 25+ bệnh, xuất Confusion Matrix và đo F1-Score (US-037 đến US-040).
   - Lượng tử hóa mô hình sang TFLite (<15MB), tích hợp suy luận offline trên app, đo latency <200ms, tách nền lá cây, kiểm tra Data Drift và cảnh báo ảnh mờ/thiếu sáng (US-041 đến US-047, US-050).
   - Lập trình màn hình Camera quét lá hoặc chọn ảnh thư viện, hiển thị tên bệnh, vẽ bản đồ nhiệt Grad-CAM (Heatmap) có thanh trượt điều chỉnh độ1 trong suốt, lưu bệnh án và chia sẻ cộng đồng (US-048, US-049, US-051 đến US-057).
2. @code-reviewer rà soát độ chính xác tích hợp mô hình TFLite và API Grad-CAM.
3. Cập nhật trạng thái các task US-037 đến US-057 thành "ĐÃ HOÀN THÀNH" trong `docs/sprint-backlog.md` và ghi log vào `docs/daily-logs/`.