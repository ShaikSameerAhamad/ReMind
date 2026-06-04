package com.remind.app.feature.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Login
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

private data class HomeTile(val title: String, val body: String, val routeKey: String?)

private val EmptyHomeTiles = listOf(
    HomeTile("Tonight Queue", "Saved links for focused evening reading appear here.", "tonight"),
    HomeTile("Reading Streak", "Complete your first read to begin a streak.", null),
    HomeTile("Family Tasks", "Create a group before assigning shared tasks.", null),
    HomeTile("Shared Alarms", "Group alarms will show delivery and dismissal status.", null),
)

@Composable
fun HomeRoute(
    onSaveClick: () -> Unit,
    onAuthClick: () -> Unit,
    onQueueClick: (String) -> Unit,
) {
    Scaffold(
        floatingActionButton = {
            FloatingActionButton(onClick = onSaveClick) {
                Icon(imageVector = Icons.Rounded.Add, contentDescription = "Save a link")
            }
        },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp, vertical = 20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            HomeHeader(onAuthClick = onAuthClick)
            LazyVerticalGrid(
                columns = GridCells.Adaptive(minSize = 156.dp),
                contentPadding = PaddingValues(bottom = 96.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(EmptyHomeTiles) { tile ->
                    HomeBentoTile(
                        tile = tile,
                        onClick = tile.routeKey?.let { key -> { onQueueClick(key) } },
                    )
                }
            }
        }
    }
}

@Composable
private fun HomeHeader(onAuthClick: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "reMind",
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.ExtraBold,
        )
        Text(
            text = "Save smarter. Sync better",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.72f),
        )
        Button(onClick = onAuthClick) {
            Icon(imageVector = Icons.Rounded.Login, contentDescription = null)
            Text(modifier = Modifier.padding(start = 8.dp), text = "Sign in")
        }
    }
}

@Composable
private fun HomeBentoTile(
    tile: HomeTile,
    onClick: (() -> Unit)?,
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick ?: {},
        enabled = onClick != null,
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = tile.title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
            )
            Text(
                text = tile.body,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f),
            )
        }
    }
}
