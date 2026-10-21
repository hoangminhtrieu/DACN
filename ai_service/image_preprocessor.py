"""
Module Tiền xử lý Ảnh, Kiểm định Chất lượng & Tách Nền Lá Cây
Mục tiêu (US-046, US-050):
1. Cảnh báo thời gian thực: Ảnh mờ, rung lắc, thiếu sáng, quá chói hoặc không chứa bộ phận lá cây.
2. Tách nền lá cây (Background Removal / Leaf Segmentation) để loại bỏ nhiễu ban công.
"""

import io
import numpy as np
from PIL import Image, ImageFilter, ImageOps

class ImageQualityAuditor:
    @staticmethod
    def audit_image_quality(image_bytes: bytes) -> dict:
        """
        US-050: Kiểm định chất lượng ảnh đầu vào trước khi đưa vào mô hình học sâu.
        """
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        img_gray = img.convert("L")
        np_gray = np.array(img_gray, dtype=np.float32)

        # 1. Đo độ mờ (Blur detection via Laplacian variance)
        # Sử dụng ma trận tích chập Laplacian giả lập xấp xỉ
        laplacian_kernel = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]], dtype=np.float32)
        # Tính toán độ biến thiên độ dốc biên cạnh
        h, w = np_gray.shape
        diff_x = np.abs(np_gray[:, 1:] - np_gray[:, :-1])
        diff_y = np.abs(np_gray[1:, :] - np_gray[:-1, :])
        blur_score = float(np.var(diff_x) + np.var(diff_y))

        is_blurry = blur_score < 45.0

        # 2. Đo độ sáng trung bình (Brightness / Exposure)
        mean_brightness = float(np.mean(np_gray))
        is_too_dark = mean_brightness < 40.0
        is_overexposed = mean_brightness > 230.0

        # 3. Kiểm tra sự hiện diện của lá cây (Chlorophyll & Foliage Tone Check trong không gian HSV)
        img_hsv = img.convert("HSV")
        np_hsv = np.array(img_hsv)
        h_channel = np_hsv[:, :, 0] # Hue (0-255)
        # Sắc tố xanh lá (Hue 35 - 90) hoặc vàng úa bệnh (Hue 20 - 35)
        green_yellow_mask = (h_channel >= 20) & (h_channel <= 95)
        plant_pixel_ratio = float(np.sum(green_yellow_mask) / (h * w))
        has_plant_parts = plant_pixel_ratio > 0.12 # Tối thiểu 12% diện tích là mô lá cây

        # Tổng hợp lỗi
        issues = []
        if is_blurry:
            issues.append("Ảnh bị rung lắc hoặc mờ nét. Vui lòng giữ chắc tay và chụp lại.")
        if is_too_dark:
            issues.append("Môi trường chụp quá tối. Hãy bật flash hoặc chụp ở nơi đủ sáng.")
        if is_overexposed:
            issues.append("Ảnh bị chói lóa ánh nắng trực tiếp. Hãy đổi góc chụp râm mát hơn.")
        if not has_plant_parts:
            issues.append("Không phát hiện bộ phận lá cây trong khung ngắm. Hãy hướng camera vào lá có đốm bệnh.")

        return {
            "is_valid_for_inference": len(issues) == 0,
            "blur_score": round(blur_score, 2),
            "brightness_score": round(mean_brightness, 2),
            "plant_pixel_ratio": round(plant_pixel_ratio, 4),
            "issues": issues
        }

    @staticmethod
    def remove_background_and_segment(image_bytes: bytes) -> bytes:
        """
        US-046: Tách nền loại bỏ cảnh quan ban công/tường gạch, chỉ giữ lại phiến lá bệnh.
        """
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        img_hsv = img.convert("HSV")
        np_hsv = np.array(img_hsv)

        # Mặt nạ màu xanh thực vật và đốm bệnh
        h_channel = np_hsv[:, :, 0]
        s_channel = np_hsv[:, :, 1]
        mask = ((h_channel >= 15) & (h_channel <= 110) & (s_channel > 30)).astype(np.uint8) * 255

        mask_img = Image.fromarray(mask).filter(ImageFilter.GaussianBlur(radius=2))
        segmented = Image.composite(img, Image.new("RGB", img.size, (240, 240, 240)), mask_img)

        out_buffer = io.BytesIO()
        segmented.save(out_buffer, format="JPEG", quality=90)
        return out_buffer.getvalue()
