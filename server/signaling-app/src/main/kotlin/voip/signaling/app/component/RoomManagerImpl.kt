package voip.signaling.app.component

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList
import org.springframework.stereotype.Component
import org.springframework.web.socket.WebSocketSession

/**
 * 1:1 통화 스파이크용 인메모리 방 저장소.
 * 서버를 여러 대로 늘리면 이 상태를 공유할 수 없으므로 단일 인스턴스 전제로만 동작한다.
 */
@Component
class RoomManagerImpl : RoomManager {

    private val rooms = ConcurrentHashMap<String, CopyOnWriteArrayList<WebSocketSession>>()
    private val roomCodesBySessionId = ConcurrentHashMap<String, String>()

    override fun joinRoom(roomCode: String, session: WebSocketSession) {
        rooms.computeIfAbsent(roomCode) { CopyOnWriteArrayList() }
            .add(session)
        roomCodesBySessionId[session.id] = roomCode
    }

    override fun isFull(roomCode: String): Boolean {
        return (rooms[roomCode]?.size ?: 0) >= CAPACITY
    }

    override fun getPeers(roomCode: String, sender: WebSocketSession): List<WebSocketSession> {
        return rooms[roomCode].orEmpty().filter { it.id != sender.id }
    }

    override fun getPeers(sender: WebSocketSession): List<WebSocketSession> {
        val roomCode = roomCodesBySessionId[sender.id] ?: return emptyList()
        return getPeers(roomCode, sender)
    }

    override fun leaveRoom(session: WebSocketSession): List<WebSocketSession> {
        val roomCode = roomCodesBySessionId.remove(session.id) ?: return emptyList()
        val room = rooms[roomCode] ?: return emptyList()
        room.removeIf { it.id == session.id }
        if (room.isEmpty()) {
            rooms.remove(roomCode, room)
        }
        return room.toList()
    }

    companion object {
        private const val CAPACITY = 2
    }
}
