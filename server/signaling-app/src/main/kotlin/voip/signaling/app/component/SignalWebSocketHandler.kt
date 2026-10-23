package voip.signaling.app.component

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.socket.CloseStatus
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.ConcurrentWebSocketSessionDecorator
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

    private fun toJsonString(obj: Any): String {
        return objectMapper.writeValueAsString(obj)
    }

    private fun handleNotSupportType(session: WebSocketSession) {
        val response = toJsonString(
            ErrorResponse(code = "NOT_SUPPORTED_TYPE")
        )
        session.sendMessage(TextMessage(response))
    }

    private fun joinResponsePair(roomCode: String?): Pair<SignalResponseType, TextMessage> {
        val response: String
        val signalResponseType: SignalResponseType
        if (roomCode.isNullOrBlank() || !roomCodePattern.matches(roomCode)) {
            signalResponseType = SignalResponseType.ERROR
            response = toJsonString(
                ErrorResponse(code = "WRONG_ROOM_CODE")
            )
        } else if (roomManager.isFull(roomCode)) {
            signalResponseType = SignalResponseType.JOIN_FAILED
            response = toJsonString(
                SignalResponse(SignalResponseType.JOIN_FAILED)
            )
        } else {
            signalResponseType = SignalResponseType.JOINED
            response = toJsonString(
                SignalResponse(SignalResponseType.JOINED)
            )
        }
        return Pair(signalResponseType, TextMessage(response))
    }

    /**
     * 한 피어가 끊겨 있어도 나머지 피어에게는 전달되도록 개별적으로 예외를 삼킨다.
     */
    private fun sendToPeers(peers: List<WebSocketSession>, message: TextMessage) {
        peers.forEach { peer ->
            try {
                peer.sendMessage(message)
            } catch (e: Exception) {
                logger.warn("failed to send message to ${peer.id}: ${e.message}", e)
            }
        }
    }

    private fun handleJoinMessage(session: WebSocketSession, request: SignalRequest) {
        val concurrentSession = ConcurrentWebSocketSessionDecorator(session, 5000, 1024 * 512)
        val roomCode = request.payload["roomCode"] as? String
        val responsePair = joinResponsePair(roomCode)
        concurrentSession.sendMessage(
            responsePair.second
        )
        if (roomCode != null && responsePair.first == SignalResponseType.JOINED) {
            roomManager.joinRoom(roomCode, concurrentSession)
            val peers = roomManager.getPeers(roomCode, concurrentSession)
            val peerJoinedResponse = toJsonString(
                SignalResponse(type = SignalResponseType.PEER_JOINED)
            )
            sendToPeers(peers, TextMessage(peerJoinedResponse))
        }
    }

    /**
     * offer/answer/ice_candidate 는 서버가 내용을 해석하지 않고 payload 를 그대로 상대에게 넘긴다.
     * SDP 와 ICE 후보는 두 단말끼리 이해하면 되는 값이라 서버가 알아야 할 이유가 없다.
     */
    private fun handleRelayMessage(
        session: WebSocketSession,
        request: SignalRequest,
        responseType: SignalResponseType
    ) {
        val peers = roomManager.getPeers(session)
        if (peers.isEmpty()) {
            logger.warn("no peer to relay ${responseType.toJson()} from ${session.id}")
            return
        }
        val response = toJsonString(
            SignalResponse(type = responseType, payload = request.payload)
        )
        sendToPeers(peers, TextMessage(response))
    }

    private fun handleLeaveMessage(session: WebSocketSession) {
        val peers = roomManager.leaveRoom(session)
        val peerLeftResponse = toJsonString(
            SignalResponse(type = SignalResponseType.PEER_LEFT)
        )
        sendToPeers(peers, TextMessage(peerLeftResponse))
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
            SignalRequestType.OFFER -> handleRelayMessage(session, request, SignalResponseType.OFFER)
            SignalRequestType.ANSWER -> handleRelayMessage(session, request, SignalResponseType.ANSWER)
            SignalRequestType.ICE_CANDIDATE -> handleRelayMessage(session, request, SignalResponseType.ICE_CANDIDATE)
            SignalRequestType.LEAVE -> handleLeaveMessage(session)
            null -> handleNotSupportType(session)
        }
    }

    /**
     * 앱 강제 종료나 네트워크 단절처럼 leave 메시지를 못 보내고 끊기는 경우가 더 흔하다.
     * 방 정리는 leave 메시지가 아니라 연결 종료 시점을 기준으로 삼는다.
     */
    override fun afterConnectionClosed(session: WebSocketSession, status: CloseStatus) {
        logger.info("session {} is closed, status code {}", session.id, status.code)
        handleLeaveMessage(session)
    }
}
