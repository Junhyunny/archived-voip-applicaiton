package voip.signaling.app.component

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler
import tools.jackson.databind.ObjectMapper
import tools.jackson.module.kotlin.jacksonObjectMapper
import voip.signaling.app.model.*

class SignalWebSocketHandler(
    private val objectMapper: ObjectMapper = jacksonObjectMapper(),
    private val roomManager: RoomManager
) : TextWebSocketHandler() {
    private val roomCodePattern = Regex("^\\d{4}$")
    private val logger: Logger = LoggerFactory.getLogger(SignalWebSocketHandler::class.java)

    private fun handleNotSupportType(session: WebSocketSession) {
        val response = objectMapper.writeValueAsString(
            ErrorResponse(code = "NOT_SUPPORTED_TYPE")
        )
        session.sendMessage(TextMessage(response))
    }

    private fun joinResponsePair(roomCode: String?): Pair<SignalResponseType, TextMessage> {
        val response: String
        val signalResponseType: SignalResponseType
        if (roomCode.isNullOrBlank() || !roomCodePattern.matches(roomCode)) {
            signalResponseType = SignalResponseType.ERROR
            response = objectMapper.writeValueAsString(
                ErrorResponse(code = "WRONG_ROOM_CODE")
            )
        } else if (roomManager.isFull(roomCode)) {
            signalResponseType = SignalResponseType.JOIN_FAILED
            response = objectMapper.writeValueAsString(
                SignalResponse(SignalResponseType.JOIN_FAILED)
            )
        } else {
            signalResponseType = SignalResponseType.JOINED
            response = objectMapper.writeValueAsString(
                SignalResponse(SignalResponseType.JOINED)
            )
        }
        return Pair(signalResponseType, TextMessage(response))
    }

    private fun handleJoinMessage(session: WebSocketSession, request: SignalRequest) {
        val roomCode = request.payload["roomCode"] as? String ?: return
        val responsePair = joinResponsePair(roomCode)
        if (responsePair.first == SignalResponseType.JOINED) {
            roomManager.joinRoom(roomCode, session)
            val peers = roomManager.getPeers(roomCode, session)
            val peerJoinedResponse = objectMapper.writeValueAsString(
                SignalResponse(type = SignalResponseType.PEER_JOINED)
            )
            peers.forEach { peer ->
                peer.sendMessage(
                    TextMessage(peerJoinedResponse)
                )
            }
        }
        session.sendMessage(
            responsePair.second
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