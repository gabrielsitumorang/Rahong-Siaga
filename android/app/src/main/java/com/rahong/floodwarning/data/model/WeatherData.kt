package com.rahong.floodwarning.data.model

/**
 * Model data cuaca yang sudah dimapping dari DTO.
 *
 * Menyimpan informasi cuaca terkini yang diperoleh dari sensor lapangan.
 *
 * @property curahHujan Curah hujan dalam milimeter (mm).
 * @property durasiHujan Durasi hujan dalam menit.
 * @property suhu Suhu udara dalam derajat Celsius (°C).
 * @property kelembapan Kelembapan relatif dalam persen (%).
 * @property deskripsi Deskripsi singkat kondisi cuaca.
 * @property timestamp Waktu pengambilan data (ISO 8601).
 */
data class WeatherData(
    val curahHujan: Double,
    val durasiHujan: Int,
    val suhu: Double,
    val kelembapan: Double,
    val deskripsi: String,
    val timestamp: String
)
