package com.example.voip.types

sealed interface SignalEvent {
    data object Connected : SignalEvent
    data object Joined : SignalEvent
    data object JoinFailed : SignalEvent
    data object PeerLeft : SignalEvent
    data object Disconnected : SignalEvent
    data object PeerJoined : SignalEvent
    data object Offer : SignalEvent
    data object Answer : SignalEvent
    data object IceCandidate : SignalEvent
}