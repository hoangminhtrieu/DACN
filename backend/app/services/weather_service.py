from typing import Dict, Any, List
import httpx
from app.schemas.garden import WeatherForecastResponse, WeatherAlert

class WeatherService:
    def __init__(self, api_key: str = "demo_weather_api_key"):
        self.api_key = api_key

    async def get_city_forecast(self, city: str = "TP. Hồ Chí Minh") -> WeatherForecastResponse:
        """
        Lấy thông tin dự báo thời tiết tại vị trí người dùng (US-031)
        Và tự động sinh các cảnh báo thông minh: Mưa lớn (US-032), Sốc nhiệt (US-033), Rét đậm (US-034).
        """
        # Dữ liệu mô phỏng theo mùa và vị trí địa lý Việt Nam
        city_lower = city.lower()
        if "hà nội" in city_lower or "ha noi" in city_lower:
            temp = 24.5
            humidity = 82
            rain_prob = 75
            condition = "Mưa rào rải rác"
        elif "đà lạt" in city_lower or "da lat" in city_lower:
            temp = 11.0 # Kích hoạt rét đậm
            humidity = 90
            rain_prob = 40
            condition = "Sương mù rét đậm"
        else: # TP.HCM mặc định
            temp = 38.5 # Kích hoạt sốc nhiệt mùa hè
            humidity = 68
            rain_prob = 80 # Mưa dông chiều
            condition = "Nắng gắt, có dông chiều"

        alerts: List[WeatherAlert] = []

        # US-033: Cảnh báo sốc nhiệt khi nhiệt độ ngoài trời > 38°C
        if temp >= 38.0:
            alerts.append(
                WeatherAlert(
                    alert_type="HEAT_WAVE",
                    severity="CRITICAL",
                    title="Cảnh báo Sốc Nhiệt (>38°C)",
                    description=f"Nhiệt độ ngoài trời hiện tại đạt {temp}°C gay gắt.",
                    recommended_action="Kéo lưới lan che nắng 50% hoặc đưa cây mọng nước, hoa hồng vào bóng râm để tránh cháy lá và sốc nhiệt bầu rễ!"
                )
            )

        # US-034: Cảnh báo rét đậm hoặc gió lốc (< 12°C)
        if temp <= 12.0:
            alerts.append(
                WeatherAlert(
                    alert_type="COLD_WAVE",
                    severity="WARNING",
                    title="Cảnh báo Rét Đậm (<12°C)",
                    description=f"Nhiệt độ giảm sâu xuống {temp}°C kèm gió lạnh buốt.",
                    recommended_action="Đưa các chậu kiểng lá nhiệt đới, cây con vào trong nhà hoặc ban công kín gió để tránh sốc nhiệt lạnh và đen chóp lá!"
                )
            )

        # US-032: Cảnh báo mưa lớn (>70%) để tự động hoãn tưới cây ban công
        if rain_prob >= 70:
            alerts.append(
                WeatherAlert(
                    alert_type="HEAVY_RAIN",
                    severity="INFO",
                    title="Dự báo Mưa Dông Chiều Tối",
                    description=f"Khả năng mưa lớn lên tới {rain_prob}%.",
                    recommended_action="Hệ thống đề xuất TỰ ĐỘNG HOÃN lịch tưới cây ngoài ban công/sân thượng hôm nay để tránh úng nước rễ chậu!"
                )
            )

        return WeatherForecastResponse(
            city=city,
            temperature_celsius=temp,
            humidity_percent=humidity,
            rain_probability_percent=rain_prob,
            weather_condition=condition,
            alerts=alerts
        )
