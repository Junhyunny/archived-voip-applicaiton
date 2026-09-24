package voip.signaling.app.component

import org.springframework.web.socket.WebSocketSession

interface RoomManager {
    fun joinRoom(roomCode: String, session: WebSocketSession)
    fun isFull(roomCode: String): Boolean
    fun getPeers(roomCode: String, sender: WebSocketSession): List<WebSocketSession>
}