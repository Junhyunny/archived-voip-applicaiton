package voip.signaling.app.component

import com.fasterxml.jackson.annotation.JsonValue
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler
import tools.jackson.databind.ObjectMapper
import tools.jackson.module.kotlin.jacksonObjectMapper

enum class SignalRequestType {
    NOT_SUPPORTED,
    JOIN;

    @JsonValue
    fun toJson(): String = name.lowercase()
}

enum class SignalResponseType {
    ERROR,
    JOINED;

    @JsonValue
    fun toJson(): String = name.lowercase()
}

data class ErrorResponse(
    val type: SignalResponseType = SignalResponseType.ERROR,
    val code: String
)

data class SignalResponse(
    val type: SignalResponseType
)

data class SignalRequest(
    val type: SignalRequestType,
    val payload: Map<String, Any?>
)

class SignalWebSocketHandler(
    val objectMapper: ObjectMapper = jacksonObjectMapper(),
) : TextWebSocketHandler() {

    private val logger: Logger = LoggerFactory.getLogger(SignalWebSocketHandler::class.java)

    private fun handleNotSupportType(session: WebSocketSession) {
        val response = objectMapper.writeValueAsString(
            ErrorResponse(code = "NOT_SUPPORTED_TYPE")
        )
        session.sendMessage(TextMessage(response))
    }

    private fun handleJoinMessage(session: WebSocketSession, request: SignalRequest) {
        val numberPattern = Regex("^\\d{4}$")
        val roomCode = request.payload["roomCode"] as? String
        val response: String
        if (roomCode.isNullOrBlank() || !numberPattern.matches(roomCode)) {
            response = objectMapper.writeValueAsString(
                ErrorResponse(code = "WRONG_ROOM_CODE")
            )
        } else {
            response = objectMapper.writeValueAsString(
                SignalResponse(SignalResponseType.JOINED)
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
        var request: SignalRequest
        try {
            request = objectMapper.readValue(message.payload, SignalRequest::class.java)
        } catch (e: Exception) {
            request = SignalRequest(SignalRequestType.NOT_SUPPORTED, mapOf())
            logger.error(e.message, e)
        }
        when (request.type) {
            SignalRequestType.JOIN -> handleJoinMessage(session, request)
            SignalRequestType.NOT_SUPPORTED -> handleNotSupportType(session)
        }
    }
}