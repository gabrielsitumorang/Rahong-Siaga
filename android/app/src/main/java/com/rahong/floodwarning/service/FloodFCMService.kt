package com.rahong.floodwarning.service

import android.util.Log
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.util.NotificationHelper

/**
 * Service untuk menerima broadcast notifikasi darurat dari Firebase Cloud Messaging (FCM).
 * Mendengarkan topic "flood_alerts" dan menampilkan alert darurat jika status mencapai Siaga/Awas.
 */
class FloodFCMService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "FloodFCMService"
        const val TOPIC_FLOOD_ALERTS = "flood_alerts"
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "Refreshed FCM Token: $token")
        // Otomatis subscribe ke topik peringatan banjir Desa Rahong
        FirebaseMessaging.getInstance().subscribeToTopic(TOPIC_FLOOD_ALERTS)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d(TAG, "Berhasil subscribe ke topik: $TOPIC_FLOOD_ALERTS")
                } else {
                    Log.e(TAG, "Gagal subscribe ke topik $TOPIC_FLOOD_ALERTS", task.exception)
                }
            }
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d(TAG, "Pesan FCM diterima dari: ${remoteMessage.from}")

        // Ekstraksi data payload berprioritas tinggi
        val data = remoteMessage.data
        if (data.isNotEmpty()) {
            val zoneName = data["zone_name"] ?: "Desa Rahong"
            val sblScoreStr = data["sbl_score"] ?: "0.0"
            val status = data["status"] ?: "Aman"
            val actionRequired = data["action_required"] ?: "Tetap waspada."
            val evacuationRoute = data["evacuation_route"] ?: "Menuju Posko Balai Desa Rahong."

            val sblScore = sblScoreStr.toDoubleOrNull() ?: 0.0
            val alertLevel = AlertLevel.fromString(status)

            Log.w(
                TAG,
                "PERINGATAN BANJIR: Zona $zoneName | Status: ${alertLevel.label} | SBL: $sblScore"
            )

            val isEmergency = alertLevel == AlertLevel.SIAGA || alertLevel == AlertLevel.AWAS

            val notificationTitle = when (alertLevel) {
                AlertLevel.AWAS -> "🚨 PERINGATAN DARURAT: BANJIR BESAR (AWAS)!"
                AlertLevel.SIAGA -> "⚠️ PERINGATAN BANJIR (SIAGA)"
                AlertLevel.WASPADA -> "ℹ️ Informasi Cuaca: Status Waspada"
                AlertLevel.AMAN -> "✅ Kondisi Aman Terkendali"
            }

            val notificationMessage = """
                Zona: $zoneName (Skor Bahaya: ${"%.1f".format(sblScore)})
                $actionRequired
                Rute Evakuasi: $evacuationRoute
            """.trimIndent()

            val notificationId = zoneName.hashCode()

            NotificationHelper.showFloodNotification(
                context = applicationContext,
                notificationId = notificationId,
                title = notificationTitle,
                message = notificationMessage,
                isEmergency = isEmergency
            )
        }
    }
}

