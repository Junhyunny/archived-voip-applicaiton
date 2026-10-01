package com.example.voip.models

import kotlinx.serialization.Serializable

@Serializable
data class JoinPayload(
    val roomCode: String
) {
}