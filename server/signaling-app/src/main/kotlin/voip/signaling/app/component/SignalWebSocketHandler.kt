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
    private val roomCodePattern = Regex("^\\d{4}$")
    private val logger: Logger = LoggerFactory.getLogger(SignalWebSocketHandler::class.java)

    private fun handleNotSupportType(session: WebSocketSession) {
        val response = objectMapper.writeValueAsString(
            ErrorResponse(code = "NOT_SUPPORTED_TYPE")
        )
        session.sendMessage(TextMessage(response))
    }

    private fun handleJoinMessage(session: WebSocketSession, request: SignalRequest) {
        val roomCode = request.payload["roomCode"] as? String
        val response: String
        if (roomCode.isNullOrBlank() || !roomCodePattern.matches(roomCode)) {
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
        val request: SignalRequest? = try {
            objectMapper.readValue(message.payload, SignalRequest::class.java)
        } catch (e: Exception) {
            logger.warn(e.message, e)
            null
        }
        when (request?.type) {
            SignalRequestType.JOIN -> handleJoinMessage(session, request)
            null -> handleNotSupportType(session)
        }
    }
}