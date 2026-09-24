package voip.signaling.app.component

import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler

class SignalWebSocketHandlerTest {

    lateinit var mockRoomManager: RoomManager
    lateinit var sut: TextWebSocketHandler
    lateinit var mockSenderSession: WebSocketSession
    lateinit var mockPeerSession: WebSocketSession

    private val joinMessage = TextMessage(
        """
        {"type": "join","payload":{"roomCode": "1234"}}
        """.trimIndent()
    )

    @BeforeEach
    fun setUp() {
        mockSenderSession = mockk(relaxed = true)
        mockPeerSession = mockk(relaxed = true)
        mockRoomManager = mockk(relaxed = true)
        sut = SignalWebSocketHandler(roomManager = mockRoomManager)
    }

    @Test
    fun given_room_is_not_full_when_message_type_is_join_then_send_joined_response() {
        every { mockRoomManager.isFull(any()) } returns false

        sut.handleMessage(mockSenderSession, joinMessage)

        val slot = slot<TextMessage>()
        verify { mockSenderSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"joined"}
        """.trimIndent(), slot.captured.payload
        )
        verify { mockRoomManager.joinRoom("1234", mockSenderSession) }
    }

    @ParameterizedTest
    @ValueSource(strings = ["1", "12", "123", "1ab2", "abcd"])
    fun given_join_request_roomCode_is_malformed_when_join_then_send_error_response(
        wrongRoomCode: String
    ) {
        val wrongMessage = TextMessage(
            """
            {"type":"join","payload":{"roomCode": "$wrongRoomCode"}}
        """.trimIndent()
        )

        sut.handleMessage(mockSenderSession, wrongMessage)

        val slot = slot<TextMessage>()
        verify { mockSenderSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"error","code":"WRONG_ROOM_CODE"}
        """.trimIndent(), slot.captured.payload
        )
        verify(exactly = 0) { mockRoomManager.joinRoom(any(), any()) }
    }

    @Test
    fun given_request_type_is_malformed_when_request_then_send_error_response() {
        val wrongMessage = TextMessage(
            """
            {"type":"notExisted"}
        """.trimIndent()
        )

        sut.handleMessage(mockSenderSession, wrongMessage)

        val slot = slot<TextMessage>()
        verify { mockSenderSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"error","code":"NOT_SUPPORTED_TYPE"}
        """.trimIndent(), slot.captured.payload
        )
        verify(exactly = 0) { mockRoomManager.joinRoom(any(), any()) }
    }

    @Test
    fun given_room_is_full_when_join_then_send_join_failed_response() {
        every { mockRoomManager.isFull(any()) } returns true

        sut.handleMessage(mockSenderSession, joinMessage)

        val slot = slot<TextMessage>()
        verify { mockSenderSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"join_failed"}
        """.trimIndent(), slot.captured.payload
        )
        verify(exactly = 0) { mockRoomManager.joinRoom(any(), any()) }
    }

    @Test
    fun given_peers_are_existed_and_success_to_join_when_join_then_send_empty_response() {
        every { mockRoomManager.isFull(any()) } returns false
        every { mockRoomManager.getPeers(any(), any()) } returns listOf(
            mockPeerSession
        )

        sut.handleMessage(mockSenderSession, joinMessage)


        val slot = slot<TextMessage>()
        verify { mockSenderSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"joined"}
        """.trimIndent(), slot.captured.payload
        )
        verify { mockRoomManager.joinRoom("1234", mockSenderSession) }

        val peersSlot = slot<WebSocketSession>()
        verify { mockRoomManager.getPeers("1234", capture(peersSlot)) }
        assertEquals(mockSenderSession, peersSlot.captured)

        val peerSlot = slot<TextMessage>()
        verify { mockPeerSession.sendMessage(capture(peerSlot)) }
        assertEquals(
            """
            {"type":"peer_joined"}
        """.trimIndent(), peerSlot.captured.payload
        )
    }

    @Test
    fun given_room_code_is_malformed_and_peers_are_existed_when_join_then_do_not_send_to_peers() {
        every { mockRoomManager.isFull(any()) } returns false
        every { mockRoomManager.getPeers(any(), any()) } returns listOf(
            mockPeerSession
        )
        val wrongMessage = TextMessage(
            """
            {"type":"join","payload":{"roomCode":"123"}}
        """.trimIndent()
        )

        sut.handleMessage(mockSenderSession, wrongMessage)

        verify(exactly = 0) { mockPeerSession.sendMessage(any()) }
    }

    @Test
    fun given_room_is_full_and_peers_are_existed_when_join_then_do_not_send_to_peers() {
        every { mockRoomManager.isFull(any()) } returns true
        every { mockRoomManager.getPeers(any(), any()) } returns listOf(
            mockPeerSession
        )

        sut.handleMessage(mockSenderSession, joinMessage)

        verify(exactly = 0) { mockPeerSession.sendMessage(any()) }
    }
}