"""
Configuration module for the Flood Early Warning System.
Modul konfigurasi untuk Sistem Peringatan Dini Banjir Desa Rahong.

Uses pydantic-settings to load environment variables from .env file.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    Pengaturan aplikasi yang dimuat dari variabel lingkungan.

    Attributes:
        OWM_API_KEY: API key untuk OpenWeatherMap.
        FCM_CREDENTIALS_PATH: Path ke file kredensial Firebase service account.
        DESA_RAHONG_LAT: Latitude koordinat Desa Rahong.
        DESA_RAHONG_LON: Longitude koordinat Desa Rahong.
        FETCH_INTERVAL_MINUTES: Interval pengambilan data cuaca (menit).
        DEBUG: Mode debug untuk pengembangan.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

    OWM_API_KEY: str = "not_set"
    FCM_CREDENTIALS_PATH: str = "firebase-service-account.json"
    DESA_RAHONG_LAT: float = -6.8500
    DESA_RAHONG_LON: float = 106.7500
    FETCH_INTERVAL_MINUTES: int = 10
    DEBUG: bool = True


# Singleton instance — import this throughout the application
# Instance singleton — impor ini di seluruh aplikasi
settings = Settings()
