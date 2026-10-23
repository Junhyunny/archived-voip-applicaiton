package voip.signaling.app.model

data class ErrorResponse(
    val type: SignalResponseType = SignalResponseType.ERROR,
    val code: String
)
