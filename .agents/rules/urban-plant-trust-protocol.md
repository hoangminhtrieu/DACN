---
trigger: always_on
---

---
trigger: always_on
description: Quy chuẩn bắt buộc về Explainable AI (Grad-CAM), Chẩn đoán phân biệt và Phác đồ Safe-First cho cây cảnh đô thị
---

# Quy chuẩn Nghiệp vụ Chẩn đoán Bệnh Cây Đô Thị

1. **Cấm trả kết quả đơn lẻ không có giải thích:**
   - Mọi API chẩn đoán bắt buộc phải trả về kèm ảnh hoặc tọa độ vùng nhiệt **Grad-CAM** chỉ rõ vị trí tổn thương trên lá kèm câu mô tả tự động (ví dụ: "Phát hiện vùng đốm bột trắng tập trung ở rìa lá").
2. **Bắt buộc có Chẩn đoán phân biệt (Differential Diagnosis):**
   - Không bao giờ hiển thị độ tin cậy tuyệt đối 100% ngay từ ảnh chụp.
   - Luôn trả về Top 2-3 bệnh có xác suất cao nhất kèm bộ **3 câu hỏi kiểm chứng chéo bằng mắt thường/xúc giác** (Có/Không). Điểm số cuối cùng phải được tính lại sau khi người dùng tick trả lời câu hỏi.
3. **Nguyên tắc điều trị "An toàn sinh học trước tiên" (Safe-First Protocol):**
   - Vì cây trồng ở ban công/trong nhà có trẻ em và vật nuôi, phác đồ xử lý trong Database và UI bắt buộc chia đúng 3 tầng tuần tự:
     * **Bước 1 (Cách ly & Cắt tỉa cơ học):** Hướng dẫn cắt bỏ lá bệnh, khử trùng kéo, tách chậu.
     * **Bước 2 (Giải pháp hữu cơ / Pha chế tại nhà):** Baking soda, nước rửa chén pha loãng, dầu Neem, tỏi ớt gừng.
     * **Bước 3 (Hoạt chất sinh học / Đặc trị):** Chỉ nêu tên hoạt chất khoa học an toàn được khuyến cáo (như *Bacillus subtilis*, *Trichoderma*, *Copper Hydroxide*), không quảng cáo tên thương mại độc hại.