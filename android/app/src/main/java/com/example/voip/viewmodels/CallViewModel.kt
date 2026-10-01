package com.example.voip.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.voip.utils.CountdownTicker
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlin.math.ceil

data class CallUiState(
    val remainSeconds: Long = 0L
)

class CallViewModel(
    val countdownTicker: CountdownTicker
) : ViewModel() {
    private val _uiState =
        MutableStateFlow(CallUiState())

    val uiState: StateFlow<CallUiState> =
        _uiState.asStateFlow()

    private var timerJob: Job? = null

    fun startTimer(durationMillis: Long) {
        timerJob?.cancel()
        timerJob = viewModelScope.launch {
            countdownTicker.start(durationMillis)
                .collect { remainTime ->
                    _uiState.update { current ->
                        current.copy(
                            remainSeconds = ceil(remainTime / 1_000.0).toLong()
                        )
                    }
                }
        }
    }
}