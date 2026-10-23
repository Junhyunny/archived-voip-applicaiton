package com.example.voip.clients

import com.example.voip.types.SignalEvent
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import mockwebserver3.MockResponse
import mockwebserver3.MockWebServer
import okhttp3.OkHttpClient
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import org.json.JSONObject
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SignalClientTests {

    private lateinit var server: MockWebServer
    private lateinit var client: OkHttpClient
    private lateinit var sut: SignalClient

    @Before
    fun setup() {
        server = MockWebServer()
        server.start()
        client = OkHttpClient()

        sut = SignalClientImpl(
            server
                .url("/signaling")
                .toString()
                .replace("http://", "ws://"),
            client
        )
    }

    @After
    fun teardown() {
        client.dispatcher.executorService.shutdown()
        server.close()
    }

    @Test
    fun when_connect_then_connected_event_is_occurred() = runTest {
        server.enqueue(
            MockResponse.Builder()
                .webSocketUpgrade(
                    object : WebSocketListener() {}
                )
                .build()
        )

        val connectJob = async {
            sut.connect()
        }

        val event = sut.events.first()

        assertEquals(
            SignalEvent.Connected,
            event
        )
        val request = server.takeRequest()
        assertEquals("/signaling", request.url.encodedPath)
        connectJob.await()
    }

    @Test
    fun when_connecting_is_failed_then_disconnected_event_is_occurred() = runTest {
        server.enqueue(
            MockResponse.Builder()
                .code(500)
                .body("internal server error")
                .build()
        )

        assertThrows(Exception::class.java) {
            runBlocking {
                sut.connect()
            }
        }
    }

    @Test
    fun when_connection_fails_after_connected_then_disconnected_event_is_emitted() = runTest {
        server.enqueue(
            MockResponse.Builder()
                .code(500)
                .body("internal server error")
                .build()
        )

        val connected = async { sut.events.first() }

        assertThrows(Exception::class.java) {
            runBlocking {
                sut.connect()
            }
        }
        assertEquals(
            SignalEvent.Disconnected,
            connected.await()
        )
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun when_job_is_cancel_while_connecting_then_socket_is_closed() = runTest {
        val socket = mockk<WebSocket>(relaxed = true)
        val mockClient = mockk<OkHttpClient>()
        every {
            mockClient.newWebSocket(any(), any())
        } returns socket
        val sut = SignalClientImpl("ws://localhost:8080/signaling", mockClient)
        val job = launch {
            sut.connect()
        }

        runCurrent()

        job.cancel()
        job.join()

        verify(exactly = 1) {
            socket.cancel()
        }
    }

    @Test(timeout = 5_000L)
    fun given_socket_is_connected_when_join_then_server_gets_join_message() = runTest {
        val receivedMessage = CompletableDeferred<String>()
        server.enqueue(
            MockResponse.Builder()
                .webSocketUpgrade(
                    object : WebSocketListener() {
                        override fun onMessage(webSocket: WebSocket, text: String) {
                            receivedMessage.complete(text)
                        }
                    }
                )
                .build()
        )
        sut.connect()

        sut.join("1234")

        val actual = receivedMessage.await()
        val json = JSONObject(actual)
        assertEquals("join", json.getString("type"))
        val payload = json.getJSONObject("payload")
        assertEquals("1234", payload.getString("roomCode"))
    }
}