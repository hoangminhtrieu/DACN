from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.services.voice_assistant_service import VietnameseVoiceAssistantService

router = APIRouter(prefix="/voice", tags=["Vietnamese Voice Assistant & STT/TTS"])

def get_voice_service() -> VietnameseVoiceAssistantService:
    return VietnameseVoiceAssistantService()

class VoiceCommandRequest(BaseModel):
    transcript_text: str

class VoiceNoteRequest(BaseModel):
    voice_transcript: str

@router.post("/command")
async def handle_voice_command(
    req: VoiceCommandRequest,
    voice_svc: VietnameseVoiceAssistantService = Depends(get_voice_service)
):
    """
    US-067, US-068: Nhận diện giọng nói tiếng Việt phương ngữ 3 miền.
    US-070: Điều khiển ứng dụng rảnh tay khi tay dính đất làm vườn.
    """
    return voice_svc.process_voice_command(req.transcript_text)

@router.post("/convert-note")
async def convert_voice_note_to_growth_log(
    req: VoiceNoteRequest,
    voice_svc: VietnameseVoiceAssistantService = Depends(get_voice_service)
):
    """
    US-072: Chuyển đổi giọng nói thành trường văn bản ghi chú nhật ký cây (trích xuất chiều cao và cột mốc).
    """
    return voice_svc.convert_voice_note_to_log(req.voice_transcript)
