package voip.signaling.app.component

import org.springframework.web.socket.WebSocketSession

interface RoomManager {
    fun joinRoom(roomCode: String, session: WebSocketSession)
    fun isFull(roomCode: String): Boolean
    fun getPeers(roomCode: String, sender: WebSocketSession): List<WebSocketSession>

    /**
     * 세션이 이미 참가한 방을 찾아 자신을 제외한 참가자를 돌려준다.
     * offer/answer/ice_candidate 중계처럼 roomCode 를 다시 받지 않는 요청에서 사용한다.
     */
    fun getPeers(sender: WebSocketSession): List<WebSocketSession>

    /**
     * 세션을 방에서 제거하고 방에 남은 참가자를 돌려준다.
     */
    fun leaveRoom(session: WebSocketSession): List<WebSocketSession>
}
