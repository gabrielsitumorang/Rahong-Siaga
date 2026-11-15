"""
Firebase Cloud Messaging (FCM) service for sending flood alert notifications.
Layanan Firebase Cloud Messaging (FCM) untuk mengirim notifikasi peringatan banjir.

Sends high-priority data messages to the "flood_alerts" topic when
any zone reaches Siaga (Warning) or Awas (Danger) status.
"""

import logging
from datetime import datetime, timezone
from typing import List, Optional

from models.schemas import FCMPayload, ZoneStatus

logger = logging.getLogger(__name__)

# Track whether Firebase has been initialized
# Lacak apakah Firebase sudah diinisialisasi
_firebase_initialized: bool = False


def _initialize_firebase() -> bool:
    """
    Initialize Firebase Admin SDK using service account credentials.
    Inisialisasi Firebase Admin SDK menggunakan kredensial service account.

    Returns:
        True if initialization succeeded, False otherwise.
    """
    global _firebase_initialized

    if _firebase_initialized:
        return True

    try:
        import firebase_admin
        from firebase_admin import credentials

        from config import settings

        cred_path = settings.FCM_CREDENTIALS_PATH

        # Check if credentials file exists
        # Periksa apakah file kredensial tersedia
        from pathlib import Path

        if not Path(cred_path).exists():
            logger.warning(
                f"File kredensial Firebase tidak ditemukan: {cred_path}. "
                f"Notifikasi FCM dinonaktifkan."
            )
            return False

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        _firebase_initialized = True
        logger.info("Firebase Admin SDK berhasil diinisialisasi.")
        return True

    except ImportError:
        logger.warning(
            "Module firebase-admin tidak tersedia. Notifikasi FCM dinonaktifkan."
        )
        return False
    except Exception as e:
        logger.error(f"Gagal menginisialisasi Firebase: {e}")
        return False


def _build_evacuation_route(zone_name: str) -> str:
    """
    Determine the recommended evacuation route based on the affected zone.
    Tentukan rute evakuasi yang direkomendasikan berdasarkan zona terdampak.

    Args:
        zone_name: Name of the affected zone.

    Returns:
        Evacuation route description string.
    """
    routes = {
        "Bantaran Sungai Rahong": (
            "Segera menuju Balai Desa Rahong melalui Jalan Desa Utama. "
            "Hindari jembatan lama. Jarak tempuh ±500m, waktu tempuh ±7 menit berjalan kaki."
        ),
        "Permukiman Inti Desa": (
            "Menuju Masjid Al-Ikhlas atau Balai Desa melalui Gang Mawar. "
            "Jika air sudah tinggi, langsung menuju Bukit Harapan via jalan setapak timur. "
            "Jarak tempuh ±300m."
        ),
        "Bukit Harapan": (
            "Zona ini sudah merupakan area evakuasi. Tetap di tempat dan bantu "
            "warga yang datang mengungsi. Koordinasi dengan petugas BPBD."
        ),
    }
    return routes.get(
        zone_name,
        "Menuju posko evakuasi terdekat. Ikuti arahan petugas BPBD setempat.",
    )


def _build_payloads(zone_statuses: List[ZoneStatus]) -> List[FCMPayload]:
    """
    Build FCM payloads for zones that have reached Siaga or Awas status.
    Bangun payload FCM untuk zona yang sudah mencapai status Siaga atau Awas.

    Args:
        zone_statuses: List of computed zone statuses.

    Returns:
        List of FCMPayload objects for zones requiring alerts.
    """
    alert_statuses = {"Siaga", "Awas"}
    payloads: List[FCMPayload] = []

    for zone in zone_statuses:
        if zone.status in alert_statuses:
            payloads.append(
                FCMPayload(
                    zone_name=zone.zone_name,
                    sbl_score=zone.sbl_score,
                    status=zone.status,
                    action_required=zone.action_required,
                    evacuation_route=_build_evacuation_route(zone.zone_name),
                    timestamp=datetime.now(timezone.utc),
                )
            )

    return payloads


async def send_flood_alerts(zone_statuses: List[ZoneStatus]) -> bool:
    """
    Send FCM notifications for zones in Siaga or Awas status.
    Kirim notifikasi FCM untuk zona dalam status Siaga atau Awas.

    Evaluates all zones and sends a high-priority data message to the
    "flood_alerts" topic for each zone exceeding the alert threshold.

    Args:
        zone_statuses: List of ZoneStatus objects from spatial_service.

    Returns:
        True if any alerts were sent (or attempted), False if no zones
        require alerting.
    """
    payloads = _build_payloads(zone_statuses)

    if not payloads:
        logger.info("Tidak ada zona yang memerlukan peringatan FCM.")
        return False

    logger.warning(
        f"PERINGATAN BANJIR: {len(payloads)} zona memerlukan notifikasi!"
    )

    # Log all payloads regardless of Firebase availability
    # Catat semua payload terlepas dari ketersediaan Firebase
    for payload in payloads:
        logger.warning(
            f"  → {payload.zone_name}: SBL={payload.sbl_score:.1f}, "
            f"Status={payload.status}"
        )

    # Attempt to send via Firebase
    # Coba kirim melalui Firebase
    if not _initialize_firebase():
        logger.info(
            "Firebase tidak tersedia. Payload dicatat di log saja (mode development)."
        )
        return True  # Return True because alerts were identified

    try:
        from firebase_admin import messaging

        for payload in payloads:
            message = messaging.Message(
                topic="flood_alerts",
                data={
                    "zone_name": payload.zone_name,
                    "sbl_score": str(payload.sbl_score),
                    "status": payload.status,
                    "action_required": payload.action_required,
                    "evacuation_route": payload.evacuation_route,
                    "timestamp": payload.timestamp.isoformat(),
                },
                android=messaging.AndroidConfig(
                    priority="high",
                    notification=messaging.AndroidNotification(
                        title=f"⚠️ PERINGATAN BANJIR - {payload.status.upper()}",
                        body=(
                            f"Zona {payload.zone_name} dalam status {payload.status}. "
                            f"{payload.action_required}"
                        ),
                        channel_id="flood_alert_channel",
                        priority="max",
                    ),
                ),
            )

            response = messaging.send(message)
            logger.info(
                f"FCM berhasil dikirim untuk {payload.zone_name}: {response}"
            )

        return True

    except Exception as e:
        logger.error(f"Gagal mengirim notifikasi FCM: {e}")
        return True  # Alerts were identified even if sending failed
