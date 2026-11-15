package com.rahong.floodwarning.domain.usecase

import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.repository.FloodRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case untuk mengambil status banjir terkini.
 *
 * Membungkus pemanggilan repository untuk mendapatkan data status banjir
 * yang mencakup analisis fuzzy global dan status per zona.
 *
 * @property repository Repository untuk akses data banjir.
 */
class GetFloodStatusUseCase @Inject constructor(
    private val repository: FloodRepository
) {

    /**
     * Menjalankan use case untuk mengambil status banjir.
     *
     * @return [Flow] yang memancarkan [Resource] berisi [FloodStatusResponse].
     */
    operator fun invoke(): Flow<Resource<FloodStatusResponse>> {
        return repository.getFloodStatus()
    }
}
