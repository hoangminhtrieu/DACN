from fastapi import APIRouter, Query
from app.services.weather_service import WeatherService
from app.schemas.garden import WeatherForecastResponse

router = APIRouter(prefix="/weather", tags=["Smart Weather & Alerts"])

@router.get("/current", response_model=WeatherForecastResponse)
async def get_current_weather(
    city: str = Query("TP. Hồ Chí Minh", description="Tên thành phố để lấy thời tiết")
):
    """
    US-031: Xem dự báo thời tiết tại vị trí người dùng.
    US-032, US-033, US-034: Tự động cảnh báo sốc nhiệt (>38°C), rét đậm (<12°C) và mưa dông hoãn tưới.
    """
    svc = WeatherService()
    return await svc.get_city_forecast(city)
