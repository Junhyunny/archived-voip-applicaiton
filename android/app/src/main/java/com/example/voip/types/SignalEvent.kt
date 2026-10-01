package com.example.voip.types

sealed interface SignalEvent {
    data object Connected : SignalEvent
    data object Disconnected : SignalEvent
}