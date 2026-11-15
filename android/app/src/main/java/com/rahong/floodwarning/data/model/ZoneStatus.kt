package com.rahong.floodwarning.data.model

import com.rahong.floodwarning.domain.model.AlertLevel

/**
 * Model data untuk status zona banjir yang sudah dimapping dari DTO.
 *
 * Digunakan di lapisan data dan presentasi setelah konversi dari [ZoneStatusDto].
 *
 * @property id Identifier unik zona (dihasilkan dari indeks atau nama).
 * @property nama Nama zona wilayah.
 * @property sblScore Skor Sub-Basin Level (SBL) — indikator risiko banjir.
 * @property status Level peringatan berdasarkan skor SBL.
 * @property koefisien Koefisien kerentanan zona.
 * @property color Kode warna heksadesimal untuk visualisasi.
 * @property geometry Daftar koordinat poligon zona (lat, lng pairs). Null jika belum dimuat.
 */
data class ZoneStatus(
    val id: String,
    val nama: String,
    val sblScore: Double,
    val status: AlertLevel,
    val koefisien: Double,
    val color: String,
    val geometry: List<Pair<Double, Double>>? = null
)
