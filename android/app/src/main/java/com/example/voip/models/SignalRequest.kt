package com.example.voip.models

import com.example.voip.types.SignalRequestType
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class SignalRequest(
    val type: SignalRequestType,
    val payload: JsonElement
) {
}