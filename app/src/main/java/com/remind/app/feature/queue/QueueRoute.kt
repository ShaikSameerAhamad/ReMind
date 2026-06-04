package com.remind.app.feature.queue

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.remind.app.core.common.ReMindEmptyState
import com.remind.app.core.common.ReMindScreenScaffold

@Composable
fun QueueRoute(onBack: () -> Unit) {
    ReMindScreenScaffold(title = "Queue", onBack = onBack) { padding ->
        ReMindEmptyState(
            modifier = Modifier.padding(padding),
            title = "Your queue is ready for real saves",
            body = "Saved articles, videos, and learning links will appear here when they match this queue.",
        )
    }
}
