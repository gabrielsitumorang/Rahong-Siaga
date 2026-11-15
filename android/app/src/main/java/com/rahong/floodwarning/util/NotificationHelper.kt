package com.rahong.floodwarning.util

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import com.rahong.floodwarning.presentation.MainActivity

/**
 * Utilitas helper untuk manajemen Notification Channel dan pembuatan Push Notification.
 */
object NotificationHelper {

    const val CHANNEL_EMERGENCY_ID = "flood_emergency_channel"
    const val CHANNEL_EMERGENCY_NAME = "Peringatan Darurat Banjir"

    const val CHANNEL_INFO_ID = "flood_info_channel"
    const val CHANNEL_INFO_NAME = "Informasi Cuaca & Banjir"

    /**
     * Membuat Notification Channel yang diperlukan pada Android 8.0 (API 26) ke atas.
     */
    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // 1. Emergency Channel (Siaga & Awas) - High Priority, Lights, Vibration
            val emergencyChannel = NotificationChannel(
                CHANNEL_EMERGENCY_ID,
                CHANNEL_EMERGENCY_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifikasi darurat bencana banjir Desa Rahong status Siaga dan Awas"
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500, 200, 1000)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }

            // 2. Info Channel (Aman & Waspada) - Normal Priority
            val infoChannel = NotificationChannel(
                CHANNEL_INFO_ID,
                CHANNEL_INFO_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Informasi rutin perkembangan cuaca dan status banjir Desa Rahong"
                enableLights(true)
                lightColor = Color.BLUE
            }

            notificationManager.createNotificationChannels(listOf(emergencyChannel, infoChannel))
        }
    }

    /**
     * Menampilkan notifikasi darurat status banjir.
     */
    fun showFloodNotification(
        context: Context,
        notificationId: Int,
        title: String,
        message: String,
        isEmergency: Boolean
    ) {
        val channelId = if (isEmergency) CHANNEL_EMERGENCY_ID else CHANNEL_INFO_ID

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(if (isEmergency) NotificationCompat.PRIORITY_MAX else NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(!isEmergency) // Jangan auto-cancel jika darurat Awas
            .setOngoing(isEmergency)
            .setSound(soundUri)
            .setContentIntent(pendingIntent)

        if (isEmergency) {
            builder.setVibrate(longArrayOf(0, 500, 200, 500, 200, 1000))
            builder.setColor(Color.RED)
        }

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, builder.build())
    }
}

