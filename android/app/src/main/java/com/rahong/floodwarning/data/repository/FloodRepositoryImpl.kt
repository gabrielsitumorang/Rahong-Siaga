package com.rahong.floodwarning.data.repository

import com.rahong.floodwarning.data.remote.ApiService
import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.data.remote.dto.GeoLayerResponse
import com.rahong.floodwarning.data.remote.dto.WeatherResponse
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.repository.FloodRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject

/**
 * Implementasi konkret dari [FloodRepository].
 *
 * Menggunakan [ApiService] (Retrofit) untuk mengambil data dari backend.
 * Setiap operasi dibungkus dalam [Flow] yang memancarkan state
 * [Resource.Loading], [Resource.Success], atau [Resource.Error].
 *
 * @property apiService Service Retrofit untuk komunikasi dengan API backend.
 */
class FloodRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : FloodRepository {

    /**
     * Mengambil status banjir terkini dari server.
     *
     * Memancarkan [Resource.Loading] saat memulai, kemudian [Resource.Success]
     * jika berhasil atau [Resource.Error] jika terjadi kegagalan.
     *
     * @return Flow yang memancarkan [Resource] berisi [FloodStatusResponse].
     */
    override fun getFloodStatus(): Flow<Resource<FloodStatusResponse>> = flow {
        emit(Resource.Loading())
        try {
            val response = apiService.getFloodStatus()
            emit(Resource.Success(response))
        } catch (e: HttpException) {
            emit(
                Resource.Error(
                    message = "Kesalahan server: ${e.code()} — ${e.message()}"
                )
            )
        } catch (e: IOException) {
            emit(
                Resource.Error(
                    message = "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."
                )
            )
        } catch (e: Exception) {
            emit(
                Resource.Error(
                    message = "Terjadi kesalahan: ${e.localizedMessage ?: "Tidak diketahui"}"
                )
            )
        }
    }

    /**
     * Mengambil data cuaca terkini dari sensor.
     *
     * @return Flow yang memancarkan [Resource] berisi [WeatherResponse].
     */
    override fun getCurrentWeather(): Flow<Resource<WeatherResponse>> = flow {
        emit(Resource.Loading())
        try {
            val response = apiService.getCurrentWeather()
            emit(Resource.Success(response))
        } catch (e: HttpException) {
            emit(
                Resource.Error(
                    message = "Kesalahan server: ${e.code()} — ${e.message()}"
                )
            )
        } catch (e: IOException) {
            emit(
                Resource.Error(
                    message = "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."
                )
            )
        } catch (e: Exception) {
            emit(
                Resource.Error(
                    message = "Terjadi kesalahan: ${e.localizedMessage ?: "Tidak diketahui"}"
                )
            )
        }
    }

    /**
     * Mengambil layer GIS (GeoJSON) untuk ditampilkan di peta.
     *
     * @return Flow yang memancarkan [Resource] berisi [GeoLayerResponse].
     */
    override fun getGeoLayers(): Flow<Resource<GeoLayerResponse>> = flow {
        emit(Resource.Loading())
        try {
            val response = apiService.getGeoLayers()
            emit(Resource.Success(response))
        } catch (e: HttpException) {
            emit(
                Resource.Error(
                    message = "Kesalahan server: ${e.code()} — ${e.message()}"
                )
            )
        } catch (e: IOException) {
            emit(
                Resource.Error(
                    message = "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."
                )
            )
        } catch (e: Exception) {
            emit(
                Resource.Error(
                    message = "Terjadi kesalahan: ${e.localizedMessage ?: "Tidak diketahui"}"
                )
            )
        }
    }
}
