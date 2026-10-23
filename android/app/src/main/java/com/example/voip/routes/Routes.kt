package com.example.voip.routes

import kotlinx.serialization.Serializable

@Serializable
data object EnterRoomRoute

@Serializable
data class CallRoute(val roomCode: String)