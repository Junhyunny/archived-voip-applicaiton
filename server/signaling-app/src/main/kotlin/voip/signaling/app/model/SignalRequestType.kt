package voip.signaling.app.model

import com.fasterxml.jackson.annotation.JsonValue

enum class SignalRequestType {
    JOIN,
    OFFER,
    ANSWER,
    ICE_CANDIDATE,
    LEAVE;

    @JsonValue
    fun toJson(): String = name.lowercase()
}
