package com.example.voip.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.voip.clients.SignalClient
import com.example.voip.types.CallStatus
import com.example.voip.types.SignalEvent
import com.example.voip.utils.CountdownTicker
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlin.math.ceil

data class CallUiState(
    val remainSeconds: Long = 0L,
    val isCountdownFinished: Boolean = false,
    val callStatus: CallStatus = CallStatus.UNCONNECTED
)

class CallViewModel(
    val countdownTicker: CountdownTicker,
    val signalClient: SignalClient
) : ViewModel() {
    private val _uiState =
        MutableStateFlow(CallUiState())

    val uiState: StateFlow<CallUiState> =
        _uiState.asStateFlow()

    private var timerJob: Job? = null
    private var callJob: Job? = null

    fun startTimer(durationMillis: Long) {
        if (timerJob?.isActive == true) {
            return
        }
        _uiState.update { current ->
            current.copy(
                remainSeconds = ceil(durationMillis / 1_000.0).toLong(),
                isCountdownFinished = false
            )
        }
        timerJob = viewModelScope.launch {
            countdownTicker.start(durationMillis)
                .collect { remainTime ->
                    _uiState.update { current ->
                        current.copy(
                            remainSeconds = ceil(remainTime / 1_000.0).toLong(),
                            isCountdownFinished = remainTime == 0L
                        )
                    }
                }
        }
    }

    fun startCall(roomCode: String) {
        if (callJob != null) {
            return
        }
        callJob = viewModelScope.launch {
            try {
                signalClient.connect()
                signalClient.join(roomCode)
            } catch (_: Exception) {
                _uiState.update { current ->
                    current.copy(
                        callStatus = CallStatus.DISCONNECTED
                    )
                }
            }
            signalClient.events.collect { event ->
                handleSignalEvent(event)
            }
        }
    }

    private fun updateCallStatus(status: CallStatus) {
        _uiState.update { current -> current.copy(callStatus = status) }
    }

    private fun handleSignalEvent(event: SignalEvent) {
        when (event) {
            SignalEvent.Connected -> updateCallStatus(CallStatus.IDLE)
            SignalEvent.Joined -> updateCallStatus(CallStatus.JOINED)
            SignalEvent.PeerJoined -> updateCallStatus(CallStatus.NEGOTIATING)
            SignalEvent.Offer -> updateCallStatus(CallStatus.NEGOTIATING)
            SignalEvent.JoinFailed,
            SignalEvent.Disconnected -> updateCallStatus(CallStatus.DISCONNECTED)

            else -> print("TODO it will be deleted when all status handling is implemented")
        }
    }

    fun close() {
        signalClient.close()
        _uiState.update { current -> current.copy(callStatus = CallStatus.DISCONNECTED) }
//        timerJob?.cancel()
//        timerJob = null
//        callJob?.cancel()
//        callJob = null
    }
}