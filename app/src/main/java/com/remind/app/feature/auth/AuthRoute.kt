package com.remind.app.feature.auth

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.remind.app.core.common.ReMindEmptyState
import com.remind.app.core.common.ReMindScreenScaffold

@Composable
fun AuthRoute(onBack: () -> Unit) {
    ReMindScreenScaffold(title = "Sign in", onBack = onBack) { padding ->
        ReMindEmptyState(
            modifier = Modifier.padding(padding),
            title = "Keep your saves and groups in sync",
            body = "Sign in to sync saved links, family tasks, shared alarms, and reading progress across devices.",
        )
    }
}
