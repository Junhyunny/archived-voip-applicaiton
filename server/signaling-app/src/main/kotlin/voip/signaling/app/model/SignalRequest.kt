package voip.signaling.app.model

data class SignalRequest(
    val type: SignalRequestType,
    val payload: Map<String, Any?>
)