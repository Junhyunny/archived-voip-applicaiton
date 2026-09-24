package voip.signaling.app.component

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

    lateinit var sut: TextWebSocketHandler

    @BeforeEach
    fun setUp() {
        sut = SignalWebSocketHandler()
    }

    @Test
    fun when_message_type_is_join_then_send_joined_response() {
        val mockWebSocketSession = mockk<WebSocketSession>(relaxed = true)
        val textMessage = TextMessage(
            """
        {"type": "join","payload":{"roomCode": "1234"}}
        """.trimIndent()
        )

        sut.handleMessage(mockWebSocketSession, textMessage)

        val slot = slot<TextMessage>()
        verify { mockWebSocketSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"joined"}
        """.trimIndent(), slot.captured.payload
        )
    }

    @ParameterizedTest
    @ValueSource(strings = ["1", "12", "123", "1ab2", "abcd"])
    fun given_join_request_roomCode_is_malformed_when_join_then_send_error_response(
        wrongRoomCode: String
    ) {
        val mockWebSocketSession = mockk<WebSocketSession>(relaxed = true)
        val textMessage = TextMessage(
            """
            {"type":"join","payload":{"roomCode": "$wrongRoomCode"}}
        """.trimIndent()
        )

        sut.handleMessage(mockWebSocketSession, textMessage)

        val slot = slot<TextMessage>()
        verify { mockWebSocketSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"error","code":"WRONG_ROOM_CODE"}
        """.trimIndent(), slot.captured.payload
        )
    }

    @Test
    fun given_request_type_is_malformed_when_request_then_send_error_response() {
        val mockWebSocketSession = mockk<WebSocketSession>(relaxed = true)
        val textMessage = TextMessage(
            """
            {"type":"notExisted"}
        """.trimIndent()
        )

        sut.handleMessage(mockWebSocketSession, textMessage)

        val slot = slot<TextMessage>()
        verify { mockWebSocketSession.sendMessage(capture(slot)) }
        assertEquals(
            """
            {"type":"error","code":"NOT_SUPPORTED_TYPE"}
        """.trimIndent(), slot.captured.payload
        )
    }
}