package com.rahong.floodwarning

import android.app.Application
import com.rahong.floodwarning.util.NotificationHelper
import dagger.hilt.android.HiltAndroidApp

/**
 * Kelas Application untuk Sistem Peringatan Dini Banjir Desa Rahong.
 * Menginisialisasi Hilt DI dan membuat notification channels.
 */
@HiltAndroidApp
class FloodWarningApp : Application() {

    override fun onCreate() {
        super.onCreate()
        NotificationHelper.createNotificationChannels(this)
    }
}
