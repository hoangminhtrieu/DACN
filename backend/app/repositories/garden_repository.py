from typing import Optional, List
from datetime import date, datetime
from sqlalchemy import select, update, delete, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.garden import (
    PlantCatalog,
    UserGarden,
    UserPlant,
    PlantGrowthLog,
    CareSchedule,
    UserVacationSetting,
    LightRequirement,
    PlantDifficulty,
    ScheduleTaskType
)

class GardenRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    # --- Plant Catalog (US-016, US-017, US-018) ---
    async def get_catalog_by_id(self, catalog_id: str) -> Optional[PlantCatalog]:
        res = await self.db.execute(select(PlantCatalog).where(PlantCatalog.id == catalog_id))
        return res.scalars().first()

    async def search_and_filter_catalog(
        self,
        query: Optional[str] = None,
        light: Optional[LightRequirement] = None,
        difficulty: Optional[PlantDifficulty] = None,
        category: Optional[str] = None
    ) -> List[PlantCatalog]:
        stmt = select(PlantCatalog)
        conditions = []

        if query:
            search_pattern = f"%{query}%"
            conditions.append(
                or_(
                    PlantCatalog.common_name_vi.ilike(search_pattern),
                    PlantCatalog.scientific_name.ilike(search_pattern),
                    PlantCatalog.plant_family.ilike(search_pattern)
                )
            )

        if light:
            conditions.append(PlantCatalog.light_requirement == light)

        if difficulty:
            conditions.append(PlantCatalog.difficulty == difficulty)

        if category:
            conditions.append(PlantCatalog.plant_category == category)

        if conditions:
            stmt = stmt.where(and_(*conditions))

        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def seed_default_catalog_if_empty(self):
        res = await self.db.execute(select(PlantCatalog).limit(1))
        if res.scalars().first() is None:
            default_plants = [
                PlantCatalog(
                    common_name_vi="Hoa Hồng Leo Mon Coeur",
                    scientific_name="Rosa 'Mon Coeur'",
                    plant_family="Rosaceae",
                    plant_category="Cây có hoa",
                    light_requirement=LightRequirement.DIRECT_SUN,
                    difficulty=PlantDifficulty.MEDIUM,
                    standard_water_interval_days=1,
                    optimal_temperature_min=20.0,
                    optimal_temperature_max=35.0,
                    image_url="https://images.unsplash.com/photo-1518709268805-4e9042af9f23",
                    description="Giống hoa hồng Nhật tuyệt đẹp, cánh cúp viền hồng nhạt, siêng hoa quanh năm tại ban công đô thị.",
                    care_instructions="Cần nắng trực tiếp tối thiểu 5-6 tiếng/ngày. Tưới đẫm vào gốc sáng sớm, tránh tưới ướt sũng lá ban đêm."
                ),
                PlantCatalog(
                    common_name_vi="Sen Đá Phật Bà",
                    scientific_name="Sempervivum calcareum",
                    plant_family="Crassulaceae",
                    plant_category="Cây mọng nước",
                    light_requirement=LightRequirement.PARTIAL_SHADE,
                    difficulty=PlantDifficulty.EASY,
                    standard_water_interval_days=5,
                    optimal_temperature_min=15.0,
                    optimal_temperature_max=32.0,
                    image_url="https://images.unsplash.com/photo-1509423350716-97f9360b4e09",
                    description="Các lớp lá xếp tầng như tòa sen, chóp lá màu đỏ tía, mang ý nghĩa may mắn cho gia chủ.",
                    care_instructions="Cần đất thoát nước nhanh (xỉ than, perlite). Chỉ tưới khi đất khô hoàn toàn (chu kỳ 4-7 ngày/lần)."
                ),
                PlantCatalog(
                    common_name_vi="Kiểng Lá Trầu Bà Lá Xẻ (Monstera Deliciosa)",
                    scientific_name="Monstera deliciosa",
                    plant_family="Araceae",
                    plant_category="Kiểng lá",
                    light_requirement=LightRequirement.INDIRECT_BRIGHT,
                    difficulty=PlantDifficulty.EASY,
                    standard_water_interval_days=3,
                    optimal_temperature_min=18.0,
                    optimal_temperature_max=30.0,
                    image_url="https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                    description="Nữ hoàng kiểng lá nội thất với những vết xẻ tự nhiên sang trọng, lọc không khí trong nhà cực tốt.",
                    care_instructions="Thích hợp vị trí phòng khách gần cửa sổ hoặc ban công có mái che. Giữ đất ẩm nhẹ, lau bụi lá thường xuyên."
                ),
                PlantCatalog(
                    common_name_vi="Cà Chua Bi Cherry Đỏ",
                    scientific_name="Solanum lycopersicum var. cerasiforme",
                    plant_family="Solanaceae",
                    plant_category="Rau quả sạch",
                    light_requirement=LightRequirement.DIRECT_SUN,
                    difficulty=PlantDifficulty.MEDIUM,
                    standard_water_interval_days=1,
                    optimal_temperature_min=20.0,
                    optimal_temperature_max=34.0,
                    image_url="https://images.unsplash.com/photo-1592841200221-a6898f307baa",
                    description="Cà chua chùm quả ngọt giòn, cực kỳ thích hợp trồng trong chậu thông minh tại ban công.",
                    care_instructions="Cần nắng nhiều để sai quả. Nhu cầu nước cao vào giai đoạn đậu quả, kết hợp bón phân hữu cơ định kỳ."
                ),
                PlantCatalog(
                    common_name_vi="Ớt Xiêm Rừng (Ớt Hiểm)",
                    scientific_name="Capsicum frutescens",
                    plant_family="Solanaceae",
                    plant_category="Rau quả sạch",
                    light_requirement=LightRequirement.DIRECT_SUN,
                    difficulty=PlantDifficulty.EASY,
                    standard_water_interval_days=2,
                    optimal_temperature_min=22.0,
                    optimal_temperature_max=36.0,
                    image_url="https://images.unsplash.com/photo-1588252303782-cb80119abd6d",
                    description="Giống ớt cay nồng thơm đặc trưng, cây khỏe, kháng sâu bệnh tốt, cho quả quanh năm.",
                    care_instructions="Cây ưa nắng, tưới nước vừa phải, không để ứ đọng đáy chậu."
                )
            ]
            for p in default_plants:
                self.db.add(p)
            await self.db.commit()

    # --- User Gardens (US-019, US-025) ---
    async def create_user_garden(self, garden: UserGarden) -> UserGarden:
        self.db.add(garden)
        await self.db.commit()
        await self.db.refresh(garden)
        return garden

    async def get_user_gardens(self, user_id: str) -> List[UserGarden]:
        res = await self.db.execute(select(UserGarden).where(UserGarden.user_id == user_id))
        return list(res.scalars().all())

    # --- User Plants (US-019 .. US-024) ---
    async def create_user_plant(self, plant: UserPlant) -> UserPlant:
        self.db.add(plant)
        await self.db.commit()
        await self.db.refresh(plant)
        return plant

    async def get_user_plant_by_id(self, plant_id: str) -> Optional[UserPlant]:
        res = await self.db.execute(select(UserPlant).where(UserPlant.id == plant_id))
        return res.scalars().first()

    async def get_user_plants(self, user_id: str, active_only: bool = True) -> List[UserPlant]:
        stmt = select(UserPlant).where(UserPlant.user_id == user_id)
        if active_only:
            stmt = stmt.where(UserPlant.is_active == True)
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def update_user_plant(self, plant: UserPlant) -> UserPlant:
        await self.db.commit()
        await self.db.refresh(plant)
        return plant

    async def delete_user_plant(self, plant: UserPlant) -> None:
        await self.db.delete(plant)
        await self.db.commit()

    # --- Growth Logs (US-022, US-026) ---
    async def add_growth_log(self, log: PlantGrowthLog) -> PlantGrowthLog:
        self.db.add(log)
        await self.db.commit()
        await self.db.refresh(log)
        return log

    async def get_growth_logs_by_plant(self, user_plant_id: str) -> List[PlantGrowthLog]:
        stmt = (
            select(PlantGrowthLog)
            .where(PlantGrowthLog.user_plant_id == user_plant_id)
            .order_by(PlantGrowthLog.log_date.desc(), PlantGrowthLog.created_at.desc())
        )
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    # --- Care Schedules (US-027 .. US-035) ---
    async def create_schedule(self, schedule: CareSchedule) -> CareSchedule:
        self.db.add(schedule)
        await self.db.commit()
        await self.db.refresh(schedule)
        return schedule

    async def get_schedules_by_user_and_date(self, user_id: str, target_date: date) -> List[CareSchedule]:
        stmt = (
            select(CareSchedule)
            .join(UserPlant, CareSchedule.user_plant_id == UserPlant.id)
            .where(
                UserPlant.user_id == user_id,
                CareSchedule.scheduled_date == target_date,
                UserPlant.is_active == True
            )
        )
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def get_schedule_by_id(self, schedule_id: str) -> Optional[CareSchedule]:
        res = await self.db.execute(select(CareSchedule).where(CareSchedule.id == schedule_id))
        return res.scalars().first()

    async def update_schedule(self, schedule: CareSchedule) -> CareSchedule:
        await self.db.commit()
        await self.db.refresh(schedule)
        return schedule

    # --- Vacation Mode (US-036) ---
    async def get_or_create_vacation_setting(self, user_id: str) -> UserVacationSetting:
        res = await self.db.execute(select(UserVacationSetting).where(UserVacationSetting.user_id == user_id))
        setting = res.scalars().first()
        if not setting:
            setting = UserVacationSetting(user_id=user_id, is_vacation_mode=False)
            self.db.add(setting)
            await self.db.commit()
            await self.db.refresh(setting)
        return setting

    async def update_vacation_setting(self, setting: UserVacationSetting) -> UserVacationSetting:
        await self.db.commit()
        await self.db.refresh(setting)
        return setting
