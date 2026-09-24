package voip.signaling.app.component

import com.fasterxml.jackson.annotation.JsonValue
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler
import tools.jackson.databind.ObjectMapper
import tools.jackson.module.kotlin.jacksonObjectMapper

enum class SignalType {
    ERROR,
    JOIN,
    JOINED;

    @JsonValue
    fun toJson(): String = name.lowercase()
}

data class ErrorResponse(
    val type: SignalType = SignalType.ERROR,
    val code: String
)

data class SignalResponse(
    val type: SignalType
)

data class SignalRequest(
    val type: SignalType,
    val payload: Map<String, Any?>
)

class SignalWebSocketHandler(
    val objectMapper: ObjectMapper = jacksonObjectMapper(),
) : TextWebSocketHandler() {

    private fun handleNotSupportType(session: WebSocketSession) {

    }

    private fun handleJoinMessage(session: WebSocketSession, request: SignalRequest) {
        val numberPattern = Regex("^\\d{4}$")
        val roomCode = request.payload["roomCode"] as String?
        var response: String
        if (roomCode.isNullOrBlank() || !numberPattern.matches(roomCode)) {
            response = objectMapper.writeValueAsString(
                ErrorResponse(code = "WRONG_ROOM_CODE")
            )
        } else {
            response = objectMapper.writeValueAsString(
                SignalResponse(SignalType.JOINED)
            )
        }
        session.sendMessage(
            TextMessage(response)
        )
    }

    override fun handleTextMessage(
        session: WebSocketSession,
        message: TextMessage
    ) {
        val request = objectMapper.readValue(message.payload, SignalRequest::class.java)
        when (request.type) {
            SignalType.JOIN -> handleJoinMessage(session, request)
            else -> handleNotSupportType(session)
        }
    }
}