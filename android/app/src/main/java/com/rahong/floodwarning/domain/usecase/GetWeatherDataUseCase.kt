package com.rahong.floodwarning.domain.usecase

import com.rahong.floodwarning.data.remote.dto.WeatherResponse
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.repository.FloodRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case untuk mengambil data cuaca terkini.
 *
 * Membungkus pemanggilan repository untuk mendapatkan informasi cuaca
 * seperti curah hujan, durasi hujan, suhu, dan kelembapan dari sensor lapangan.
 *
 * @property repository Repository untuk akses data cuaca.
 */
class GetWeatherDataUseCase @Inject constructor(
    private val repository: FloodRepository
) {

    /**
     * Menjalankan use case untuk mengambil data cuaca.
     *
     * @return [Flow] yang memancarkan [Resource] berisi [WeatherResponse].
     */
    operator fun invoke(): Flow<Resource<WeatherResponse>> {
        return repository.getCurrentWeather()
    }
}
