package com.example.voip.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.voip.viewmodels.CallUiState
import com.example.voip.viewmodels.CallViewModel

@Composable
fun CallScreen(
    viewModel: CallViewModel,
    roomCode: String,
    durationMillis: Long,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) {
        viewModel.startTimer(durationMillis)
    }
    CallScreenContent(roomCode, uiState)
}

@Composable
fun CallScreenContent(roomCode: String, uiState: CallUiState) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("연결중")
        Text(roomCode)
        Text("상대방이 입장했어요")
        Text("음성을 연결하고 있어요")
        Text("잠시 후 통화 화면으로 이동합니다")
        Text("시그널링 서버 연결")
        Text("상대방 입장")
        Text("${uiState.remainSeconds}초 후 자동 종료")
        Button({}) { Text("취소") }
    }
}