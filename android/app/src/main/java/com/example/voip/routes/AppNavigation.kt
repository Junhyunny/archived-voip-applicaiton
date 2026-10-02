package com.example.voip.routes

import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import androidx.navigation.toRoute
import com.example.voip.AppContainer
import com.example.voip.clients.SignalClientImpl
import com.example.voip.screens.CallScreen
import com.example.voip.screens.EnterRoomScreen
import com.example.voip.viewmodels.CallViewModel
import okhttp3.OkHttpClient

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

fun NavGraphBuilder.callScreen(
    appContainer: AppContainer,
    onTimerFinished: () -> Unit
) {
    composable<CallRoute> { entry ->
        val route = entry.toRoute<CallRoute>()
        val roomCode = route.roomCode
        CallScreen(
            viewModel {
                CallViewModel(
                    appContainer.countdownTicker,
                    SignalClientImpl(
                        url = "ws://192.168.0.4:8080/signaling",
                        httpClient = OkHttpClient(),
                    )
                )
            },
            roomCode = roomCode,
            durationMillis = 60_000L,
            moveBack = onTimerFinished
        )
    }
}