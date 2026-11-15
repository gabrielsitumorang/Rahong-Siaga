package com.rahong.floodwarning.presentation.dashboard

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.presentation.components.AlertBanner
import com.rahong.floodwarning.presentation.components.StatusCard
import com.rahong.floodwarning.presentation.components.ZoneChip
import com.rahong.floodwarning.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel,
    onNavigateToMap: () -> Unit = {}
) {
    val state by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Peringatan Dini Banjir",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold)
                        )
                        Text(
                            text = "Desa Rahong - Sistem Cerdas Fuzzy Logic",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { viewModel.loadData() }) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = "Muat Ulang")
                    }
                    IconButton(onClick = onNavigateToMap) {
                        Icon(imageVector = Icons.Default.Map, contentDescription = "Buka Peta")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            if (state.isLoading && state.floodStatus == null) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // 1. Emergency Alert Banner (Siaga / Awas)
                    item {
                        AlertBanner(
                            highestAlert = state.highestAlert,
                            affectedZoneName = state.affectedZoneName,
                            actionMessage = if (state.highestAlert == AlertLevel.AWAS) {
                                "Segera lakukan evakuasi mandiri ke titik kumpul aman (Balai Desa/Masjid Al-Ikhlas)."
                            } else {
                                "Petugas desa dan warga diharap siaga. Amankan dokumen penting dan pantau sempadan sungai."
                            },
                            onEvacuateClick = onNavigateToMap
                        )
                    }

                    // 2. Weather Section Header
                    item {
                        Text(
                            text = "Kondisi Cuaca Terkini",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            modifier = Modifier.padding(top = 8.dp, bottom = 4.dp)
                        )
                    }

                    // Weather cards
                    val weather = state.weather
                    item {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            StatusCard(
                                title = "Curah Hujan",
                                value = "${weather?.rainfallMm ?: 0.0} mm",
                                subtitle = "Intensitas hujan saat ini",
                                indicatorColor = PrimaryBlue,
                                modifier = Modifier.weight(1f)
                            )
                            StatusCard(
                                title = "Durasi Hujan",
                                value = "${weather?.durationHours ?: 0.0} Jam",
                                subtitle = "Estimasi akumulasi",
                                indicatorColor = SecondaryTeal,
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    // 3. Fuzzy Logic Output Section
                    item {
                        Text(
                            text = "Analisis Mesin Fuzzy Mamdani",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            modifier = Modifier.padding(top = 12.dp, bottom = 4.dp)
                        )
                    }

                    val fuzzy = state.floodStatus?.fuzzyGlobal
                    val zScore = fuzzy?.crispOutputZ ?: 0.0
                    val globalAlert = AlertLevel.fromString(fuzzy?.statusBahaya ?: "Aman")

                    item {
                        StatusCard(
                            title = "Probabilitas Bahaya Global (Z*)",
                            value = "${"%.1f".format(zScore)}%",
                            subtitle = "Status: ${globalAlert.label} (Defuzzifikasi Centroid)",
                            indicatorColor = when (globalAlert) {
                                AlertLevel.AMAN -> FloodGreen
                                AlertLevel.WASPADA -> FloodYellowDark
                                AlertLevel.SIAGA -> FloodOrange
                                AlertLevel.AWAS -> FloodRed
                            }
                        )
                    }

                    // 4. Per-Zone SBL Section
                    item {
                        Text(
                            text = "Zonasi Risiko Desa Rahong (SBL)",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            modifier = Modifier.padding(top = 12.dp, bottom = 4.dp)
                        )
                    }

                    val zones = state.floodStatus?.zones ?: emptyList()
                    items(zones) { zone ->
                        val zoneAlert = AlertLevel.fromSblScore(zone.sblScore)
                        ZoneChip(
                            zoneName = zone.nama,
                            sblScore = zone.sblScore,
                            alertLevel = zoneAlert,
                            onClick = onNavigateToMap
                        )
                    }

                    item {
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = onNavigateToMap,
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue)
                        ) {
                            Icon(imageVector = Icons.Default.Map, contentDescription = null)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(text = "Lihat Peta Risiko Interaktif")
                        }
                        Spacer(modifier = Modifier.height(24.dp))
                    }
                }
            }
        }
    }
}

