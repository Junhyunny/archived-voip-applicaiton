package voip.signaling.app.model

import com.fasterxml.jackson.annotation.JsonValue

enum class SignalResponseType {
    ERROR,
    JOINED,
    JOIN_FAILED,
    PEER_JOINED;

    @JsonValue
    fun toJson(): String = name.lowercase()
}