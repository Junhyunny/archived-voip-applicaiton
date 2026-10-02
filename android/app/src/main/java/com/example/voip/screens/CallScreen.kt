package com.example.voip.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.voip.types.CallStatus
import com.example.voip.viewmodels.CallUiState
import com.example.voip.viewmodels.CallViewModel

@Composable
fun CallScreen(
    viewModel: CallViewModel,
    roomCode: String,
    durationMillis: Long,
    moveBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) {
        viewModel.startTimer(durationMillis)
        viewModel.startCall(roomCode)
    }
    val isEnded = uiState.isCountdownFinished || uiState.callStatus == CallStatus.DISCONNECTED
    LaunchedEffect(isEnded) {
        if (isEnded) {
            moveBack()
        }
    }
    CallScreenContent(roomCode, uiState, onEndCall = { viewModel.close() })
}

@Composable
fun CallScreenContent(roomCode: String, uiState: CallUiState, onEndCall: () -> Unit = {}) {
    when (uiState.callStatus) {
        CallStatus.CONNECTED -> ConnectedScreen(roomCode, onEndCall)
        else -> ConnectingScreen(roomCode, uiState, onEndCall)
    }
}

@Composable
fun ConnectingScreen(roomCode: String, uiState: CallUiState, onEndCall: () -> Unit = {}) {
    val isServerConnected = {
        uiState.callStatus == CallStatus.JOINED || uiState.callStatus == CallStatus.NEGOTIATING
    }
    val isPeerJoined = {
        uiState.callStatus == CallStatus.NEGOTIATING
    }
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
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Start,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = isServerConnected(),
                onCheckedChange = {},
                modifier = Modifier.testTag("joined")
            )
            Text("시그널링 서버 연결")
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Start,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = isPeerJoined(),
                onCheckedChange = {},
                modifier = Modifier.testTag("peer_joined")
            )
            Text("상대방 입장")
        }
        Text("${uiState.remainSeconds}초 후 자동 종료")
        Button(onEndCall) { Text("취소") }
    }
}

@Composable
fun ConnectedScreen(roomCode: String, onEndCall: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("연결됨 · P2P")
        Text(roomCode)
        Text("방 코드 $roomCode 로 통화 중")
        Text("AI가 통화를 듣고 있어요")
        Text("자막은 표시하지 않습니다. 통화가 끝나면 요약이 만들어집니다.")
        Button(onEndCall) { Text("통화 종료") }
    }
}