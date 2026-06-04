package com.remind.app.feature.alarms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.remind.app.core.designsystem.ReMindPalette

@Composable
fun AlarmReceivedRoute(onDismiss: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ReMindPalette.Ink)
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            text = "Shared alarm",
            style = MaterialTheme.typography.displayLarge,
            fontWeight = FontWeight.ExtraBold,
            color = ReMindPalette.Cloud,
        )
        Text(
            modifier = Modifier.padding(top = 12.dp),
            text = "Open reMind to review the group alarm, delivery state, and dismissal status.",
            style = MaterialTheme.typography.bodyLarge,
            color = ReMindPalette.Cloud.copy(alpha = 0.78f),
        )
        Button(
            modifier = Modifier.padding(top = 32.dp),
            onClick = onDismiss,
        ) {
            Text(text = "Dismiss")
        }
    }
}
