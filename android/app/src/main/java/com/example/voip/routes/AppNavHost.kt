package com.example.voip.routes

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.rememberNavController
import com.example.voip.AppContainer

@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    appContainer: AppContainer
) {
    NavHost(
        navController = navController,
        startDestination = EnterRoomRoute,
        modifier = Modifier
    ) {
        enterRoomScreen(
            onCallStartClick = navController::moveToCallScreen
        )
        callScreen(
            appContainer = appContainer,
            onTimerFinished = { navController.popBackStack() }
        )
    }
}