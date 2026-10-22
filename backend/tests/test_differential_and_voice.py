import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_verification_questions_us_058_060():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        res = await ac.get("/api/v1/treatment/questions/Rose___Powdery_Mildew")
        assert res.status_code == 200
        data = res.json()
        assert len(data["questions"]) >= 3
        # Đảm bảo có ảnh mẫu minh họa triệu chứng (US-060)
        assert data["questions"][0]["sample_illustration_url"] is not None

@pytest.mark.asyncio
async def test_recalculate_confidence_normal_us_061():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "primary_disease_code": "Rose___Powdery_Mildew",
            "initial_confidence": 0.80,
            "answers": {
                "q_powder_wipe": True,
                "q_spider_web": False,
                "q_leaf_curl": True
            }
        }
        res = await ac.post("/api/v1/treatment/verify", json=payload)
        assert res.status_code == 200
        data = res.json()
        verif = data["verification_result"]
        # Lau sạch bột phấn và lá xoăn -> Độ tin cậy tăng
        assert verif["final_confidence"] > 0.85
        assert verif["spread_risk"] == "HIGH"
        # Đảm bảo trả về phác đồ Safe-First
        assert "recommended_safe_first_protocol" in data

@pytest.mark.asyncio
async def test_differential_diverted_to_spider_mites_us_062():
    """US-062: Phát hiện côn trùng chích hút (Nhện đỏ) thay vì nấm bệnh"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "primary_disease_code": "Rose___Powdery_Mildew",
            "initial_confidence": 0.75,
            "answers": {
                "q_spider_web": True, # Có tơ nhện li ti và bọ bò
                "q_powder_wipe": False
            }
        }
        res = await ac.post("/api/v1/treatment/verify", json=payload)
        assert res.status_code == 200
        verif = res.json()["verification_result"]
        assert verif["is_diverted_to_pest"] is True
        assert "Nhện Đỏ" in verif["final_disease_name_vi"]
        assert verif["pathogen_type"] == "INSECT_PEST"

@pytest.mark.asyncio
async def test_differential_diverted_to_iron_deficiency_us_063():
    """US-063: Phát hiện thiếu vi lượng sắt thay vì nấm truyền nhiễm"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "primary_disease_code": "General___Iron_Deficiency_Chlorosis",
            "initial_confidence": 0.70,
            "answers": {
                "q_vein_green": True # Thịt lá vàng nhưng gân lá vẫn xanh
            }
        }
        res = await ac.post("/api/v1/treatment/verify", json=payload)
        assert res.status_code == 200
        verif = res.json()["verification_result"]
        assert verif["is_diverted_to_deficiency"] is True
        assert verif["spread_risk"] == "NONE"
        assert verif["pathogen_type"] == "NUTRIENT_DEFICIENCY"

@pytest.mark.asyncio
async def test_safe_first_protocol_us_075_to_079():
    """US-075..US-079: Phác đồ 3 tầng tuần tự, tỷ lệ pha và an toàn thú cưng"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        res = await ac.get("/api/v1/treatment/protocol/Rose___Powdery_Mildew")
        assert res.status_code == 200
        data = res.json()
        assert "Cách ly" in data["step_1_isolation_pruning"]
        assert "Baking Soda" in data["step_2_organic_home_remedy"]
        assert "Bacillus subtilis" in data["step_3_bio_pesticide"]
        assert "5g Baking Soda" in data["dosage_formula"]
        assert "AN TOÀN CHO TRẺ EM" in data["pet_and_child_safety_warning"]

@pytest.mark.asyncio
async def test_voice_hands_free_commands_us_067_to_072():
    """US-067..US-072: Nhận diện giọng nói tiếng Việt rảnh tay & chuyển ghi chú nhật ký"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # 1. Khẩu lệnh "Đã tưới nước"
        res_cmd1 = await ac.post("/api/v1/voice/command", json={"transcript_text": "Mình vừa tưới xong cây rồi nhé"})
        assert res_cmd1.status_code == 200
        assert res_cmd1.json()["detected_intent"] == "ACTION_COMPLETE_WATERING"

        # 2. Khẩu lệnh "Mở camera quét bệnh"
        res_cmd2 = await ac.post("/api/v1/voice/command", json={"transcript_text": "Mở máy ảnh quét lá xem bị bệnh gì"})
        assert res_cmd2.status_code == 200
        assert res_cmd2.json()["detected_intent"] == "OPEN_SCANNER"

        # 3. Chuyển giọng nói thành nhật ký
        res_note = await ac.post("/api/v1/voice/convert-note", json={"voice_transcript": "Hôm nay cây hồng cao 35cm và đã đơm 2 nụ hoa to"})
        assert res_note.status_code == 200
        data_note = res_note.json()
        assert data_note["extracted_height_cm"] == 35.0
        assert "Đơm nụ" in data_note["suggested_milestone"]
