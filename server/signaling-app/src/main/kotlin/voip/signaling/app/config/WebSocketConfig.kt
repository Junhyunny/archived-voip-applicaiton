package voip.signaling.app.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.socket.config.annotation.EnableWebSocket
import org.springframework.web.socket.config.annotation.WebSocketConfigurer
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry
import voip.signaling.app.component.RoomManager
import voip.signaling.app.component.SignalWebSocketHandler

@Configuration
@EnableWebSocket
class WebSocketConfig(
    private val roomManager: RoomManager,
    /**
     * 네이티브 클라이언트는 Origin 헤더를 보내지 않아 이 목록과 무관하게 통과한다.
     * 브라우저에서 붙을 때 아무 오리진이나 허용되지 않도록 화이트리스트를 유지한다.
     */
    @Value("\${signaling.allowed-origins}") private val allowedOrigins: Array<String>
) : WebSocketConfigurer {

    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        registry.addHandler(signalWebSocketHandler(), SIGNALING_PATH)
            .setAllowedOriginPatterns(*allowedOrigins)
    }

    @Bean
    fun signalWebSocketHandler(): SignalWebSocketHandler {
        return SignalWebSocketHandler(roomManager = roomManager)
    }

    companion object {
        private const val SIGNALING_PATH = "/signaling"
    }
}
