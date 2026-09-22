package com.example.voip.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import com.example.voip.components.Keypad

@Composable
fun EnterRoomScreen() {
    var roomCode by remember { mutableStateOf("") }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("방코드")
        Text("두 기기에 같은 코드를 입력하세요")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            for (index in 0..<4) {
                Text(
                    roomCode.getOrNull(index)?.toString() ?: "",
                    modifier = Modifier.testTag("room_code_digit_${index}")
                )
            }
        }
        Keypad(onKeyPress = {
            roomCode += it.label
        })
        Button(
            onClick = {},
            enabled = roomCode.length == 4,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("통화 시작")
        }
    }
}