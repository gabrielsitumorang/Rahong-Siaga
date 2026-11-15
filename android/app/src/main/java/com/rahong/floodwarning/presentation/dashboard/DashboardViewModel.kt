package com.rahong.floodwarning.presentation.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.data.remote.dto.WeatherResponse
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.usecase.GetFloodStatusUseCase
import com.rahong.floodwarning.domain.usecase.GetWeatherDataUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DashboardUiState(
    val isLoading: Boolean = false,
    val weather: WeatherResponse? = null,
    val floodStatus: FloodStatusResponse? = null,
    val highestAlert: AlertLevel = AlertLevel.AMAN,
    val affectedZoneName: String = "",
    val errorMessage: String? = null
)

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val getFloodStatusUseCase: GetFloodStatusUseCase,
    private val getWeatherDataUseCase: GetWeatherDataUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState(isLoading = true))
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        loadData()
        startPeriodicRefresh()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }

            // 1. Fetch current weather
            getWeatherDataUseCase().collect { resource ->
                when (resource) {
                    is Resource.Success -> {
                        _uiState.update { it.copy(weather = resource.data) }
                    }
                    is Resource.Error -> {
                        _uiState.update { it.copy(errorMessage = resource.message) }
                    }
                    is Resource.Loading -> {}
                }
            }

            // 2. Fetch flood status & SBL per zone
            getFloodStatusUseCase().collect { resource ->
                when (resource) {
                    is Resource.Success -> {
                        val status = resource.data
                        var maxAlert = AlertLevel.AMAN
                        var dangerZone = ""

                        status?.zones?.forEach { zone ->
                            val alert = AlertLevel.fromSblScore(zone.sblScore)
                            if (alert.ordinal > maxAlert.ordinal) {
                                maxAlert = alert
                                dangerZone = zone.nama
                            }
                        }

                        _uiState.update {
                            it.copy(
                                isLoading = false,
                                floodStatus = status,
                                highestAlert = maxAlert,
                                affectedZoneName = dangerZone
                            )
                        }
                    }
                    is Resource.Error -> {
                        _uiState.update {
                            it.copy(
                                isLoading = false,
                                errorMessage = resource.message
                            )
                        }
                    }
                    is Resource.Loading -> {}
                }
            }
        }
    }

    private fun startPeriodicRefresh() {
        viewModelScope.launch {
            while (true) {
                delay(10 * 60 * 1000L) // 10 menit
                loadData()
            }
        }
    }
}

