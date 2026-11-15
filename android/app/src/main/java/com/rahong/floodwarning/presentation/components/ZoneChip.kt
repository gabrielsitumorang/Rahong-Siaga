package com.rahong.floodwarning.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.presentation.theme.*

/**
 * Komponen chip untuk menampilkan status ringkas setiap zona wilayah Desa Rahong.
 */
@Composable
fun ZoneChip(
    zoneName: String,
    sblScore: Double,
    alertLevel: AlertLevel,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {}
) {
    val (bgColor, textColor, dotColor) = when (alertLevel) {
        AlertLevel.AMAN -> Triple(FloodGreenSurface, FloodGreenDark, FloodGreen)
        AlertLevel.WASPADA -> Triple(FloodYellowSurface, FloodYellowDark, FloodYellow)
        AlertLevel.SIAGA -> Triple(FloodOrangeSurface, FloodOrangeDark, FloodOrange)
        AlertLevel.AWAS -> Triple(FloodRedSurface, FloodRedDark, FloodRed)
    }

    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(8.dp),
        color = bgColor,
        modifier = modifier.padding(vertical = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(horizontal = 12.dp, vertical = 8.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .background(color = dotColor, shape = CircleShape)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = zoneName,
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = textColor
                )
            }

            Text(
                text = "${alertLevel.label} (SBL: ${"%.1f".format(sblScore)})",
                style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                color = textColor
            )
        }
    }
}

