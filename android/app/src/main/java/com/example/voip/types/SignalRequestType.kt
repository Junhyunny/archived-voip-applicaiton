package com.example.voip.types

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class SignalRequestType {
    @SerialName("join")
    JOIN
}