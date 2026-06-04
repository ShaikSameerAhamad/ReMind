package com.remind.app.core.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.remind.app.feature.alarms.AlarmReceivedRoute
import com.remind.app.feature.auth.AuthRoute
import com.remind.app.feature.home.HomeRoute
import com.remind.app.feature.queue.QueueRoute
import com.remind.app.feature.save.SaveRoute

@Composable
fun ReMindNavHost() {
    val navController = rememberNavController()
    NavHost(
        navController = navController,
        startDestination = ReMindRoute.Home.pattern,
    ) {
        composable(ReMindRoute.Home.pattern) {
            HomeRoute(
                onSaveClick = { navController.navigate(ReMindRoute.Save.pattern) },
                onAuthClick = { navController.navigate(ReMindRoute.Auth.pattern) },
                onQueueClick = { queueId -> navController.navigate(ReMindRoute.Queue.createRoute(queueId)) },
            )
        }
        composable(ReMindRoute.Auth.pattern) {
            AuthRoute(onBack = { navController.popBackStack() })
        }
        composable(ReMindRoute.Save.pattern) {
            SaveRoute(onBack = { navController.popBackStack() })
        }
        composable(ReMindRoute.Queue.pattern) {
            QueueRoute(onBack = { navController.popBackStack() })
        }
        composable(ReMindRoute.AlarmReceived.pattern) {
            AlarmReceivedRoute(onDismiss = { navController.navigate(ReMindRoute.Home.pattern) })
        }
    }
}
