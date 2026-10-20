from datetime import date, datetime, timedelta
from typing import List, Optional, Tuple, Dict, Any
from fastapi import HTTPException, status
from app.models.garden import (
    UserPlant,
    PlantCatalog,
    CareSchedule,
    ScheduleTaskType,
    PlantGrowthLog,
    UserVacationSetting
)
from app.repositories.garden_repository import GardenRepository
from app.services.weather_service import WeatherService

class SmartScheduleService:
    def __init__(self, garden_repo: GardenRepository, weather_service: WeatherService):
        self.garden_repo = garden_repo
        self.weather_service = weather_service

    async def generate_smart_schedules_for_user(self, user_id: str, target_date: Optional[date] = None) -> List[CareSchedule]:
        """
        US-027: Tự động sinh lịch tưới nước chuẩn hóa dựa trên đặc tính sinh học của từng cây.
        US-032: Tự động phát hiện mưa dông để đề xuất hoãn tưới cây ngoài ban công tránh úng rễ.
        US-036: Kiểm tra chế độ 'Đi vắng/Nghỉ dưỡng' để điều chỉnh nhắc nhở.
        """
        if not target_date:
            target_date = date.today()

        plants = await self.garden_repo.get_user_plants(user_id, active_only=True)
        vacation_setting = await self.garden_repo.get_or_create_vacation_setting(user_id)
        
        # Lấy dự báo thời tiết tại thành phố
        forecast = await self.weather_service.get_city_forecast("TP. Hồ Chí Minh")
        is_heavy_rain = forecast.rain_probability_percent >= 70

        # Lấy lịch hiện tại trong ngày đã có
        existing_schedules = await self.garden_repo.get_schedules_by_user_and_date(user_id, target_date)
        existing_plant_ids = {s.user_plant_id for s in existing_schedules}

        generated_schedules: List[CareSchedule] = list(existing_schedules)

        for plant in plants:
            if plant.id in existing_plant_ids:
                continue

            # Xác định chu kỳ tưới (ngày): ưu tiên tùy chỉnh người dùng (US-030), sau đó theo catalog
            water_interval = plant.custom_water_interval_days or 2
            if plant.catalog_id:
                cat = await self.garden_repo.get_catalog_by_id(plant.catalog_id)
                if cat and not plant.custom_water_interval_days:
                    water_interval = cat.standard_water_interval_days

            # Xác định cây có đặt ngoài ban công/sân thượng chịu mưa không
            loc_lower = plant.location_tag.lower()
            is_outdoor_location = "ban công" in loc_lower or "sân thượng" in loc_lower or "ngoài trời" in loc_lower

            # Kiểm tra quy tắc hoãn do thời tiết (US-032)
            should_weather_skip = False
            skip_note = None

            if is_heavy_rain and is_outdoor_location:
                should_weather_skip = True
                skip_note = f"Mưa dông lớn ({forecast.rain_probability_percent}%) - Tự động hoãn tưới để bảo vệ rễ cây!"

            # Kiểm tra chế độ đi vắng (US-036)
            if vacation_setting.is_vacation_mode:
                skip_note = "Chế độ 'Đi vắng/Nghỉ dưỡng' đang bật - Đã tạm dừng chuông nhắc nhở!"

            schedule = CareSchedule(
                user_plant_id=plant.id,
                task_type=ScheduleTaskType.WATERING,
                scheduled_date=target_date,
                scheduled_time="07:00",
                is_completed=False,
                weather_skip_flag=should_weather_skip,
                skip_reason=skip_note
            )
            created = await self.garden_repo.create_schedule(schedule)
            generated_schedules.append(created)

        return generated_schedules

    async def perform_schedule_action(self, schedule_id: str, action: str, postpone_days: int = 1) -> CareSchedule:
        """
        US-029: Thao tác nhanh 'Đã tưới' (COMPLETE) hoặc 'Hoãn 1 ngày' (POSTPONE).
        """
        schedule = await self.garden_repo.get_schedule_by_id(schedule_id)
        if not schedule:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy lịch chăm sóc.")

        if action.upper() == "COMPLETE":
            schedule.is_completed = True
            schedule.completed_at = datetime.utcnow()
        elif action.upper() == "POSTPONE":
            # Hoãn sang ngày hôm sau
            schedule.scheduled_date = schedule.scheduled_date + timedelta(days=postpone_days)
            schedule.skip_reason = f"Người dùng chủ động hoãn {postpone_days} ngày"
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Hành động không hợp lệ.")

        return await self.garden_repo.update_schedule(schedule)

    async def generate_plant_report(self, plant_id: str) -> Dict[str, Any]:
        """
        US-026: Xuất báo cáo lịch sử chăm sóc và nhật ký sinh trưởng của cây (PDF/JSON format).
        """
        plant = await self.garden_repo.get_user_plant_by_id(plant_id)
        if not plant:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy cây trong vườn.")

        logs = await self.garden_repo.get_growth_logs_by_plant(plant_id)
        catalog = await self.garden_repo.get_catalog_by_id(plant.catalog_id) if plant.catalog_id else None

        return {
            "report_title": f"Báo Cáo Sức Khỏe & Lịch Sử Sinh Trưởng: {plant.custom_name}",
            "generated_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
            "plant_summary": {
                "custom_name": plant.custom_name,
                "common_name": catalog.common_name_vi if catalog else "Chưa phân loại",
                "scientific_name": catalog.scientific_name if catalog else "N/A",
                "location_tag": plant.location_tag,
                "planted_date": str(plant.planted_date),
                "health_status": plant.health_status,
                "pot_size_cm": plant.pot_size_cm
            },
            "growth_timeline": [
                {
                    "date": str(log.log_date),
                    "height_cm": log.height_cm,
                    "milestone": log.growth_milestone,
                    "note": log.note,
                    "photo_url": log.photo_url
                }
                for log in logs
            ],
            "recommendations": "Duy trì bón phân hữu cơ định kỳ 15 ngày/lần và thường xuyên kiểm tra mặt dưới của lá để phát hiện sớm nấm phấn trắng hoặc nhện đỏ."
        }
