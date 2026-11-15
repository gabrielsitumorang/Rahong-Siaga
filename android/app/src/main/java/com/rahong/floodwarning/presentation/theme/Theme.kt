package com.rahong.floodwarning.presentation.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

/**
 * Skema warna terang untuk aplikasi.
 */
private val LightColorScheme = lightColorScheme(
    primary = PrimaryBlue,
    onPrimary = OnPrimary,
    primaryContainer = PrimaryBlueLight,
    onPrimaryContainer = PrimaryBlueDark,
    secondary = SecondaryTeal,
    onSecondary = OnSecondary,
    secondaryContainer = SecondaryTealLight,
    onSecondaryContainer = SecondaryTealDark,
    background = BackgroundLight,
    onBackground = OnSurfaceLight,
    surface = SurfaceLight,
    onSurface = OnSurfaceLight,
    error = ErrorRed,
    onError = OnError,
    surfaceVariant = BackgroundLight,
    onSurfaceVariant = OnSurfaceLight
)

/**
 * Skema warna gelap untuk aplikasi.
 */
private val DarkColorScheme = darkColorScheme(
    primary = PrimaryBlueLight,
    onPrimary = PrimaryBlueDark,
    primaryContainer = PrimaryBlue,
    onPrimaryContainer = OnPrimary,
    secondary = SecondaryTealLight,
    onSecondary = SecondaryTealDark,
    secondaryContainer = SecondaryTeal,
    onSecondaryContainer = OnSecondary,
    background = BackgroundDark,
    onBackground = OnSurfaceDark,
    surface = SurfaceDark,
    onSurface = OnSurfaceDark,
    error = FloodRedLight,
    onError = FloodRedDark,
    surfaceVariant = BackgroundDark,
    onSurfaceVariant = OnSurfaceDark
)

/**
 * Tema utama Sistem Peringatan Dini Banjir Desa Rahong.
 *
 * Menggunakan Material3 (Material You) dengan dukungan Dynamic Color
 * pada perangkat Android 12+ (API 31). Pada perangkat yang lebih lama,
 * menggunakan skema warna statis yang telah dikonfigurasi.
 *
 * @param darkTheme Apakah menggunakan tema gelap. Default mengikuti pengaturan sistem.
 * @param dynamicColor Apakah menggunakan dynamic color (hanya Android 12+). Default true.
 * @param content Konten Composable yang akan diwarnai oleh tema ini.
 */
@Composable
fun FloodWarningTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = FloodWarningTypography,
        content = content
    )
}
