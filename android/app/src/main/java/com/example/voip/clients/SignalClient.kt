package com.example.voip.clients

import com.example.voip.models.JoinPayload
import com.example.voip.models.SignalRequest
import com.example.voip.types.SignalEvent
import com.example.voip.types.SignalRequestType
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToJsonElement
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

interface SignalClient {
    val events: Flow<SignalEvent>
    suspend fun connect()
    fun join(roomCode: String)
}

class SignalClientImpl(
    private val url: String,
    private val httpClient: OkHttpClient,
    private val json: Json = Json { ignoreUnknownKeys = true }
) : SignalClient {

    private val _events = Channel<SignalEvent>(Channel.BUFFERED)
    override val events: Flow<SignalEvent> = _events.receiveAsFlow()

    @Volatile
    private var webSocket: WebSocket? = null

    override suspend fun connect() = suspendCancellableCoroutine { continuation ->
        val request = Request.Builder().url(url).build()
        val socket = httpClient.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                super.onOpen(webSocket, response)
                this@SignalClientImpl.webSocket = webSocket
                _events.trySend(SignalEvent.Connected)
                continuation.resume(Unit)
            }

            override fun onMessage(webSocket: WebSocket, text: String) {
                handleTextMessage(text)
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                this@SignalClientImpl.webSocket = null
                if (continuation.isActive) {
                    continuation.resumeWithException(t)
                }
                _events.trySend(SignalEvent.Disconnected)
            }
        })

        continuation.invokeOnCancellation { socket.cancel() }
    }

    private fun handleTextMessage(text: String) {}

    override fun join(roomCode: String) {
        val text = json.encodeToString(
            SignalRequest(
                SignalRequestType.JOIN,
                json.encodeToJsonElement(JoinPayload(roomCode))
            )
        )
        webSocket?.send(text)
    }
}