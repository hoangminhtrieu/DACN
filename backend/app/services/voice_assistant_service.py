import re
from typing import Dict, Any

class VietnameseVoiceAssistantService:
    def __init__(self):
        # Từ điển ý định khẩu lệnh rảnh tay (Hands-free Voice Intents)
        self.intent_patterns = {
            "ACTION_COMPLETE_WATERING": [
                r"đã tưới", r"tưới xong", r"xong nước", r"tưới rồi", r"đã làm"
            ],
            "ACTION_POSTPONE_WATERING": [
                r"hoãn tưới", r"mai tưới", r"hôm nay mưa", r"để mai", r"hoãn 1 ngày"
            ],
            "OPEN_SCANNER": [
                r"quét bệnh", r"chụp ảnh", r"mở máy ảnh", r"quét lá", r"khám cây"
            ],
            "ASK_NEEM_OIL": [
                r"pha dầu neem", r"cách pha neem", r"tỷ lệ neem", r"dầu neem"
            ],
            "ASK_WATER_FREQUENCY": [
                r"bao lâu tưới", r"mấy ngày tưới", r"chu kỳ tưới"
            ]
        }

    def process_voice_command(self, transcript_text: str) -> Dict[str, Any]:
        """
        US-067, US-068, US-070: Phân tích khẩu lệnh tiếng Việt rảnh tay của người làm vườn.
        """
        text_clean = transcript_text.lower().strip()
        matched_intent = "UNKNOWN"
        reply_spoken_text = "Tôi đã nghe rõ nhưng chưa nhận diện được yêu cầu. Bạn có thể nói 'Đã tưới cây', 'Hoãn 1 ngày', hoặc 'Quét bệnh lá'."
        action_payload = {}

        for intent, patterns in self.intent_patterns.items():
            if any(re.search(p, text_clean) for p in patterns):
                matched_intent = intent
                break

        if matched_intent == "ACTION_COMPLETE_WATERING":
            reply_spoken_text = "Đã ghi nhận bạn đã tưới nước cho cây thành công!"
            action_payload = {"action": "COMPLETE"}
        elif matched_intent == "ACTION_POSTPONE_WATERING":
            reply_spoken_text = "Đã hoãn lịch tưới thêm một ngày theo yêu cầu của bạn!"
            action_payload = {"action": "POSTPONE", "days": 1}
        elif matched_intent == "OPEN_SCANNER":
            reply_spoken_text = "Đang mở camera quét bệnh bằng trí tuệ nhân tạo..."
            action_payload = {"navigate_to": "CAMERA_SCANNER"}
        elif matched_intent == "ASK_NEEM_OIL":
            reply_spoken_text = "Công thức pha dầu Neem an toàn: Pha 5ml dầu Neem nguyên chất cùng 2ml nước rửa chén sinh học vào 1 lít nước ấm, lắc đều và phun ướt 2 mặt lá vào chiều mát."
            action_payload = {"topic": "NEEM_OIL_RECIPE"}
        elif matched_intent == "ASK_WATER_FREQUENCY":
            reply_spoken_text = "Với hoa hồng ngoài ban công, bạn nên tưới đẫm vào mỗi buổi sáng. Với sen đá, chỉ tưới khi đất khô hoàn toàn, từ 4 đến 7 ngày một lần."
            action_payload = {"topic": "WATER_FREQUENCY"}

        return {
            "original_transcript": transcript_text,
            "detected_intent": matched_intent,
            "reply_spoken_text": reply_spoken_text, # Văn bản để Text-to-Speech đọc to (US-069)
            "action_payload": action_payload
        }

    def convert_voice_note_to_log(self, voice_text: str) -> Dict[str, Any]:
        """
        US-072: Chuyển đổi giọng nói ghi âm thành trường ghi chú nhật ký cây tự động.
        """
        text_clean = voice_text.strip()
        # Trích xuất chiều cao nếu có nhắc đến cm (vd: "Cây cao ba mươi phân", "Cây cao 32cm")
        height_match = re.search(r"(\d+(\.\d+)?)\s*(cm|phân)", text_clean)
        extracted_height = float(height_match.group(1)) if height_match else None

        # Trích xuất cột mốc
        milestone = "Theo dõi định kỳ"
        if "nụ" in text_clean or "hoa" in text_clean:
            milestone = "Đơm nụ / Nở hoa"
        elif "chồi" in text_clean or "lá non" in text_clean:
            milestone = "Ra đọt non mới"
        elif "thay chậu" in text_clean:
            milestone = "Sang chậu mới"

        return {
            "transcript": voice_text,
            "extracted_height_cm": extracted_height,
            "suggested_milestone": milestone,
            "formatted_note": text_clean
        }
