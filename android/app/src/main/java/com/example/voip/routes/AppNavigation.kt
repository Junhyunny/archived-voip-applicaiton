package com.example.voip.routes

import androidx.navigation.NavController
import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import androidx.navigation.toRoute
import com.example.voip.screens.CallScreen
import com.example.voip.screens.EnterRoomScreen

fun NavController.moveToCallScreen(roomCode: String) {
    navigate(CallRoute(roomCode))
}

fun NavGraphBuilder.enterRoomScreen(
    onCallStartClick: (String) -> Unit
) {
    composable<EnterRoomRoute> {
        EnterRoomScreen(onCallStartClick = onCallStartClick)
    }
}

fun NavGraphBuilder.callScreen() {
    composable<CallRoute> { entry ->
        val route = entry.toRoute<CallRoute>()
        val roomCode = route.roomCode
        CallScreen(roomCode = roomCode)
    }
}