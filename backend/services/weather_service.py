"""
Weather service for fetching current weather data from OpenWeatherMap API.
Layanan cuaca untuk mengambil data cuaca terkini dari API OpenWeatherMap.

Features:
- Fetches real-time weather from OWM Current Weather API
- Estimates rainfall duration from recent forecast data
- Provides fallback mock data for development/testing
"""

import logging
from datetime import datetime, timezone
from typing import Any, Dict, Optional

import httpx

from config import settings
from models.schemas import WeatherData

logger = logging.getLogger(__name__)

# OpenWeatherMap API base URL
OWM_BASE_URL = "https://api.openweathermap.org/data/2.5"


# Open-Meteo API base URL (100% Gratis & Tanpa API Key)
OPEN_METEO_BASE_URL = "https://api.open-meteo.com/v1/forecast"


async def fetch_current_weather() -> WeatherData:
    """
    Fetch current weather data for Desa Rahong.
    Prioritas 1: Open-Meteo API (Real-time, tanpa API key).
    Prioritas 2: OpenWeatherMap (jika OWM_API_KEY diset).
    Prioritas 3: Mock data fallback.
    """
    try:
        return await _fetch_from_open_meteo()
    except Exception as e:
        logger.warning(f"Gagal mengambil data dari Open-Meteo: {e}. Mencoba OWM...")

    if settings.OWM_API_KEY != "not_set":
        try:
            return await _fetch_from_owm()
        except Exception as e:
            logger.warning(f"Gagal mengambil data dari OWM: {e}.")

    logger.info("Menggunakan data cuaca fallback/mock.")
    return _generate_mock_weather()


async def _fetch_from_open_meteo() -> WeatherData:
    """
    Mengambil data presipitasi realtime dan riwayat jam-jaman dari Open-Meteo.
    """
    params = {
        "latitude": settings.DESA_RAHONG_LAT,
        "longitude": settings.DESA_RAHONG_LON,
        "current": "temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,wind_speed_10m",
        "hourly": "precipitation,rain",
        "past_hours": 12,
        "forecast_hours": 1,
        "timezone": "Asia/Jakarta",
    }

    async with httpx.AsyncClient(timeout=8.0) as client:
        resp = await client.get(OPEN_METEO_BASE_URL, params=params)
        resp.raise_for_status()
        data = resp.json()

        curr = data.get("current", {})
        hourly = data.get("hourly", {})

        rain_mm = float(curr.get("precipitation") or curr.get("rain") or 0.0)
        temp_c = float(curr.get("temperature_2m") or 27.0)
        humidity = float(curr.get("relative_humidity_2m") or 80.0)
        wind = float(curr.get("wind_speed_10m") or 2.0)
        wmo = int(curr.get("weather_code") or 0)

        # Hitung durasi jam hujan berkelanjutan dari hourly
        hourly_precip = hourly.get("precipitation", [])
        duration_hours = 0.0
        for p in reversed(hourly_precip):
            if float(p or 0.0) > 0.1:
                duration_hours += 1.0
            else:
                if duration_hours > 0.0:
                    break
        if duration_hours == 0.0 and rain_mm > 0.0:
            duration_hours = 0.5

        def decode_wmo(code: int) -> str:
            if code == 0:
                return "Cerah"
            if 1 <= code <= 3:
                return "Cerah Berawan / Mendung"
            if 45 <= code <= 48:
                return "Berkabut"
            if 51 <= code <= 55:
                return "Gerimis"
            if 61 <= code <= 63:
                return "Hujan Sedang"
            if code >= 65:
                return "Hujan Lebat"
            if 80 <= code <= 82:
                return "Hujan Deras Disertai Angin"
            if code >= 95:
                return "Badai Petir"
            return "Hujan"

        return WeatherData(
            timestamp=datetime.now(timezone.utc),
            temperature_celsius=temp_c,
            humidity_percent=humidity,
            weather_description=f"{decode_wmo(wmo)} (Open-Meteo Realtime)",
            wind_speed_mps=wind,
            rainfall_mm=rain_mm,
            estimated_duration_hours=round(duration_hours, 1),
            source="Open-Meteo Realtime API",
            is_mock=False,
        )


async def _fetch_from_owm() -> WeatherData:
    """
    Fetch weather data from OpenWeatherMap Current Weather API.
    Mengambil data cuaca dari API Current Weather OpenWeatherMap.

    Calls two endpoints:
    1. /weather — current conditions (temperature, humidity, wind, rain)
    2. /forecast — 5-day/3-hour forecast to estimate ongoing rain duration

    Returns:
        WeatherData: Parsed weather data.

    Raises:
        httpx.HTTPStatusError: If the API returns a non-2xx response.
    """
    params_current: Dict[str, Any] = {
        "lat": settings.DESA_RAHONG_LAT,
        "lon": settings.DESA_RAHONG_LON,
        "appid": settings.OWM_API_KEY,
        "units": "metric",
        "lang": "id",
    }

    async with httpx.AsyncClient(timeout=15.0) as client:
        # Fetch current weather / Ambil cuaca terkini
        resp_current = await client.get(
            f"{OWM_BASE_URL}/weather", params=params_current
        )
        resp_current.raise_for_status()
        current_data = resp_current.json()

        # Fetch forecast for duration estimation / Ambil prakiraan untuk estimasi durasi
        params_forecast = {**params_current}
        resp_forecast = await client.get(
            f"{OWM_BASE_URL}/forecast", params=params_forecast
        )
        resp_forecast.raise_for_status()
        forecast_data = resp_forecast.json()

    # Extract rainfall (mm in last 1h or 3h)
    # Ekstrak curah hujan (mm dalam 1 jam atau 3 jam terakhir)
    rain_data = current_data.get("rain", {})
    rainfall_mm = rain_data.get("1h", rain_data.get("3h", 0.0))

    # Estimate duration from forecast: count consecutive rainy periods
    # Estimasi durasi dari prakiraan: hitung periode hujan berturut-turut
    estimated_duration = _estimate_duration_from_forecast(forecast_data)

    weather_desc = ""
    if current_data.get("weather"):
        weather_desc = current_data["weather"][0].get("description", "Tidak diketahui")

    return WeatherData(
        timestamp=datetime.now(timezone.utc),
        temperature_celsius=current_data.get("main", {}).get("temp", 0.0),
        humidity_percent=current_data.get("main", {}).get("humidity", 0.0),
        weather_description=weather_desc,
        wind_speed_mps=current_data.get("wind", {}).get("speed", 0.0),
        rainfall_mm=rainfall_mm,
        estimated_duration_hours=estimated_duration,
        source="OpenWeatherMap",
        is_mock=False,
    )


def _estimate_duration_from_forecast(forecast_data: Dict[str, Any]) -> float:
    """
    Estimate rainfall duration from OWM 5-day/3-hour forecast data.
    Estimasi durasi hujan dari data prakiraan 5-hari/3-jam OWM.

    Counts consecutive 3-hour forecast periods that include rain,
    starting from the most recent. Each rainy period adds 3 hours.

    Args:
        forecast_data: Raw JSON response from /forecast endpoint.

    Returns:
        Estimated rain duration in hours (float).
    """
    forecast_list = forecast_data.get("list", [])
    if not forecast_list:
        return 0.0

    consecutive_rain_hours = 0.0

    for entry in forecast_list[:8]:  # Look at next 24 hours (8 × 3h periods)
        rain = entry.get("rain", {})
        rain_3h = rain.get("3h", 0.0)

        if rain_3h > 0:
            consecutive_rain_hours += 3.0
        else:
            # Stop at first non-rainy period
            # Berhenti pada periode non-hujan pertama
            break

    # Cap at 12 hours (universe max) / Batasi pada 12 jam (maks universe)
    return min(consecutive_rain_hours, 12.0)


def _generate_mock_weather() -> WeatherData:
    """
    Generate mock weather data for development and testing.
    Menghasilkan data cuaca mock untuk pengembangan dan pengujian.

    Simulates moderate-to-heavy rainfall conditions for testing
    the fuzzy engine response.

    Returns:
        WeatherData: Mock weather observation.
    """
    return WeatherData(
        timestamp=datetime.now(timezone.utc),
        temperature_celsius=26.5,
        humidity_percent=89.0,
        weather_description="Hujan lebat",
        wind_speed_mps=3.2,
        rainfall_mm=65.0,
        estimated_duration_hours=5.5,
        source="Mock Data (Development)",
        is_mock=True,
    )
