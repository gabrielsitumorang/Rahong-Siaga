"""
Weather API route for Desa Rahong flood early warning system.
Router API cuaca untuk sistem peringatan dini banjir Desa Rahong.

Provides real-time weather information, rainfall intensity, and estimated duration.
"""

import logging
from fastapi import APIRouter, HTTPException, status

from models.schemas import WeatherData
from services.weather_service import fetch_current_weather

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/weather", tags=["Weather"])


@router.get(
    "/current",
    response_model=WeatherData,
    summary="Dapatkan Data Cuaca Terkini Desa Rahong",
    description=(
        "Mengambil data cuaca real-time untuk Desa Rahong (suhu, kelembapan, "
        "kecepatan angin, presipitasi curah hujan mm, dan estimasi durasi hujan)."
    ),
)
async def get_current_weather() -> WeatherData:
    """
    Fetch current weather observation for Desa Rahong.
    Ambil data observasi cuaca terkini untuk Desa Rahong.
    """
    try:
        weather_data = await fetch_current_weather()
        return weather_data
    except Exception as e:
        logger.error(f"Error fetching current weather: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal mengambil data cuaca: {str(e)}",
        )

