package voip.signaling.app.model

import com.fasterxml.jackson.annotation.JsonValue

enum class SignalRequestType {
    JOIN;

    @JsonValue
    fun toJson(): String = name.lowercase()
}