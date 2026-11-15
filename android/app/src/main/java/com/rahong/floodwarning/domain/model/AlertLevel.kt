package com.rahong.floodwarning.domain.model

/**
 * Enum yang merepresentasikan level peringatan banjir.
 *
 * Setiap level memiliki label dalam Bahasa Indonesia dan kode warna
 * heksadesimal untuk visualisasi di peta dan UI.
 *
 * Level peringatan ditentukan berdasarkan skor SBL (Skor Bahaya Lokal):
 * - **AMAN**: 0 ≤ SBL ≤ 35 — Hijau, Kondisi normal / tidak ada ancaman.
 * - **WASPADA**: 36 ≤ SBL ≤ 60 — Kuning, Siaga aparat & warga.
 * - **SIAGA**: 61 ≤ SBL ≤ 80 — Oranye, Push notification broadcast darurat.
 * - **AWAS**: 81 ≤ SBL ≤ 100 — Merah, Alarm sirene darurat + evakuasi segera.
 *
 * @property label Nama level peringatan dalam Bahasa Indonesia.
 * @property colorHex Kode warna heksadesimal untuk tampilan visual.
 */
enum class AlertLevel(val label: String, val colorHex: String) {

    /** Kondisi aman (0-35), tidak ada ancaman banjir. */
    AMAN("Aman", "#4CAF50"),

    /** Kondisi waspada (36-60), siaga aparat dan warga. */
    WASPADA("Waspada", "#FFEB3B"),

    /** Kondisi siaga (61-80), potensi bahaya tinggi, broadcast notifikasi. */
    SIAGA("Siaga", "#FF9800"),

    /** Kondisi awas / evakuasi (81-100), bahaya ekstrem, evakuasi segera. */
    AWAS("Awas / Evakuasi", "#F44336");

    companion object {

        /**
         * Memetakan skor SBL (Skor Bahaya Lokal) ke [AlertLevel] yang sesuai.
         *
         * @param score Skor SBL dalam rentang 0–100.
         * @return [AlertLevel] berdasarkan ambang batas spesifikasi teknis.
         */
        fun fromSblScore(score: Double): AlertLevel {
            return when {
                score > 80.0 -> AWAS
                score > 60.0 -> SIAGA
                score > 35.0 -> WASPADA
                else -> AMAN
            }
        }

        /**
         * Memetakan string status ke [AlertLevel].
         *
         * @param status String status (case-insensitive), misalnya "Aman", "Waspada".
         * @return [AlertLevel] yang cocok, atau [AMAN] sebagai default.
         */
        fun fromString(status: String): AlertLevel {
            return when (status.lowercase().trim()) {
                "aman" -> AMAN
                "waspada" -> WASPADA
                "siaga" -> SIAGA
                "awas", "awas / evakuasi", "evakuasi" -> AWAS
                else -> AMAN
            }
        }
    }
}
