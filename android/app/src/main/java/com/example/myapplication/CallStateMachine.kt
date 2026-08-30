package com.example.myapplication

class CallStateMachine {
    fun transition(currentState: CallState, event: CallEvent): CallState {
        if (event == CallEvent.Disconnect) {
            return CallState.Disconnected
        }
        return when (currentState) {
            CallState.Idle -> if (event == CallEvent.StartOutgoing) CallState.Dialing else CallState.Idle
            CallState.Dialing -> if (event == CallEvent.Connected) CallState.Active else CallState.Dialing
            CallState.Holding -> if (event == CallEvent.Resume) CallState.Active else CallState.Holding
            CallState.Active -> if (event == CallEvent.Hold) CallState.Holding else CallState.Active
            CallState.Disconnected -> CallState.Disconnected
        }
    }
}
