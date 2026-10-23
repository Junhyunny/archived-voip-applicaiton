package voip.signaling.app.model

import com.fasterxml.jackson.annotation.JsonInclude

/**
 * payload 를 nullable + NON_NULL 로 두어 join 응답은 {"type":"joined"} 모양을 그대로 유지한다.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
data class SignalResponse(
    val type: SignalResponseType,
    val payload: Map<String, Any?>? = null
)
