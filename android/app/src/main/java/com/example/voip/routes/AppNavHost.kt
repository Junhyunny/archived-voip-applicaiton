package com.example.voip.routes

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.rememberNavController

@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
) {
    NavHost(
        navController = navController,
        startDestination = EnterRoomRoute,
        modifier = Modifier
    ) {
        enterRoomScreen(
            onCallStartClick = navController::moveToCallScreen
        )
        callScreen()
    }
}