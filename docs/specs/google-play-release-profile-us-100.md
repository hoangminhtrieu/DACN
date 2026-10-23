# HỒ SƠ PHÁT HÀNH ỨNG DỤNG LÊN GOOGLE PLAY STORE (US-100)

- **Người thực hiện:** `@senior-dev` & `@qa-tester`
- **Mã User Story:** `US-100` (Chuẩn bị hồ sơ Google Play Developer, chính sách bảo mật, bộ ảnh chụp và đưa app lên Store)
- **Trạng thái:** **SẴN SÀNG PHÁT HÀNH CHÍNH THỨC (READY FOR STORE DEPLOYMENT)**

---

## I. THÔNG TIN NIÊM YẾT TRÊN CỬA HÀNG (STORE LISTING METADATA)

### 1. Tên ứng dụng & Định danh
- **App Name:** `Urban Plants: Bác Sĩ Cây Cảnh AI`
- **Package Name:** `com.urbanplants.app`
- **Default Language:** `vi-VN` (Tiếng Việt) & `en-US` (Tiếng Anh)
- **Category:** House & Home / Education / Tools

### 2. Mô tả ngắn (Short Description - Dưới 80 ký tự)
`Bác sĩ AI chẩn đoán bệnh lá cây đô thị, bản đồ Grad-CAM & phác đồ Safe-First.`

### 3. Mô tả chi tiết (Full Description)
```text
Chào mừng bạn đến với Urban Plants — Ứng dụng Bác sĩ Cây trồng Đô thị thông minh hàng đầu tại Việt Nam!

Bạn đam mê trồng hoa hồng, sen đá, kiểng lá, cà chua bi ngoài ban công chung cư hay sân thượng nhưng thường xuyên gặp cảnh:
- Lá cây bị đốm vàng, cháy rìa, phủ lớp phấn trắng lạ?
- Đang làm vườn tay dính bùn đất, không tiện chạm vào điện thoại?
- Muốn chữa bệnh cho cây nhưng sợ thuốc trừ sâu độc hại ảnh hưởng đến trẻ nhỏ và thú cưng (chó, mèo)?

Urban Plants mang đến giải pháp toàn diện:
1. BÁC SĨ CÂY AI & BẢN ĐỒ NHIỆT GRAD-CAM:
Chỉ cần hướng camera vào lá cây, AI On-Device nhận diện chính xác 25+ loại sâu bệnh trong 125ms ngay cả khi mất mạng Internet. Bản đồ nhiệt Grad-CAM trực quan giúp bạn thấy rõ vùng lá đang bị tổn thương.

2. CHẨN ĐOÁN PHÂN BIỆT & PHÁC ĐỒ SAFE-FIRST 3 BƯỚC:
Không lo dùng sai thuốc! Bộ 3 câu hỏi kiểm chứng chéo giúp phân biệt chính xác giữa Nấm bệnh, Nhện đỏ chích hút và Hiện tượng thiếu vi chất (Sắt/Magie). Phác đồ Safe-First 3 tầng ưu tiên giải pháp cắt tỉa cơ học và chế phẩm hữu cơ nhà làm (Baking soda, Dầu Neem ép lạnh) trước khi dùng vi sinh sinh học an toàn.

3. TRỢ LÝ GIỌNG NÓI TIẾNG VIỆT RẢNH TAY:
Nhận diện giọng nói chuẩn xác 3 miền Bắc - Trung - Nam. Chỉ cần nói "Đã tưới nước" hoặc "Mở camera quét bệnh", bạn có thể điều khiển ứng dụng không cần chạm tay.

4. LỊCH CHĂM SÓC THÍCH ỨNG THỜI TIẾT:
Tự động đề xuất hoãn lịch tưới khi trời có mưa dông, cảnh báo sốc nhiệt ban công vượt quá 38°C để che lưới kịp thời.

5. TƯ VẤN 1-1 VỚI CHUYÊN GIA & VẬT TƯ GẦN NHẤT:
Đặt lịch tư vấn trực tuyến qua Video Call với các Kỹ sư Nông nghiệp hàng đầu và tra cứu các cửa hàng vật tư uy tín quanh khu vực sinh sống.

Hãy tải ngay Urban Plants để cùng xây dựng khu vườn ban công xanh mướt, an lành cho cả gia đình!
```

---

## II. DANH SÁCH QUYỀN TRUY CẬP (APP PERMISSIONS) & BẢO MẬT

Các quyền khai báo trong `AndroidManifest.xml` tuân thủ nghiêm ngặt chính sách Google Play:
1. `android.permission.CAMERA`: Dùng để chụp ảnh lá cây phục vụ suy luận mô hình AI (chỉ kích hoạt khi mở màn hình Scanner).
2. `android.permission.RECORD_AUDIO`: Dùng cho trợ lý giọng nói tiếng Việt rảnh tay (chỉ thu âm khi bấm micro hoặc trong chế độ Hands-free).
3. `android.permission.ACCESS_FINE_LOCATION`: Dùng để lấy tọa độ thời tiết ban công và tìm cửa hàng vật tư nông nghiệp gần nhất.
4. `android.permission.POST_NOTIFICATIONS`: Gửi thông báo nhắc lịch tưới nước và xịt thuốc sau 3 ngày.
5. **Tiêu chuẩn dữ liệu:** Tuân thủ quyền riêng tư người dùng; cung cấp tùy chọn xóa tài khoản vĩnh viễn theo chính sách mới của Google Play.

- **Chính sách bảo mật (Privacy Policy URL):** `https://urbanplants.vn/privacy-policy`

---

## III. THÔNG SỐ KỸ THUẬT BẢN BUILD (RELEASE ARTIFACTS)

- **Target SDK Version:** `34` (Android 14)
- **Minimum SDK Version:** `24` (Android 7.0 Nougat - Bao phủ 96.8% thiết bị Android trên toàn cầu)
- **Format:** `Android App Bundle (.aab)` với Play App Signing được quản lý bởi Google Cloud KMS.
- **Tối ưu mã nguồn:** ProGuard / R8 enabled, Shrink Resources enabled.
- **Phân loại độ tuổi (Content Rating):** `PEGI 3 / Everyone` (Mọi lứa tuổi).
