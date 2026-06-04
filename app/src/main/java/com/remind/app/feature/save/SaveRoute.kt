package com.remind.app.feature.save

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.remind.app.core.common.ReMindEmptyState
import com.remind.app.core.common.ReMindScreenScaffold

@Composable
fun SaveRoute(onBack: () -> Unit) {
    ReMindScreenScaffold(title = "Save", onBack = onBack) { padding ->
        ReMindEmptyState(
            modifier = Modifier.padding(padding),
            title = "Save your first link",
            body = "Paste a secure link or share one from another Android app to start building your queue.",
        )
    }
}
