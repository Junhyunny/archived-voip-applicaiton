import com.example.myapplication.CallEvent
import com.example.myapplication.CallState
import com.example.myapplication.CallStateMachine
import org.junit.Assert.assertEquals
import org.junit.Test

class CallStateMachineTest {
    @Test
    fun given_disconnected_when_connected_arrives_then_keep_disconnected() {
        val stateMachine = CallStateMachine()
        val currentState = CallState.Disconnected
        val nextState = stateMachine.transition(
            currentState = currentState,
            event = CallEvent.Connected
        )

        assertEquals(CallState.Disconnected, nextState)
    }

    @Test
    fun given_idle_when_start_outgoing_arrives_then_move_to_dialing() {
        val stateMachine = CallStateMachine()
        val nextState = stateMachine.transition(
            currentState = CallState.Idle,
            event = CallEvent.StartOutgoing
        )

        assertEquals(CallState.Dialing, nextState)
    }

    @Test
    fun given_dialing_when_connected_arrives_then_move_to_active() {
        val stateMachine = CallStateMachine()
        val nextState = stateMachine.transition(
            currentState = CallState.Dialing,
            event = CallEvent.Connected
        )

        assertEquals(CallState.Active, nextState)
    }

    @Test
    fun given_active_when_hold_arrives_then_move_to_holding() {
        val stateMachine = CallStateMachine()
        val nextState = stateMachine.transition(
            currentState = CallState.Active,
            event = CallEvent.Hold
        )

        assertEquals(CallState.Holding, nextState)
    }

    @Test
    fun given_holding_when_resume_arrives_then_move_to_active() {
        val stateMachine = CallStateMachine()
        val nextState = stateMachine.transition(
            currentState = CallState.Holding,
            event = CallEvent.Resume
        )

        assertEquals(CallState.Active, nextState)
    }

    @Test
    fun given_any_state_when_disconnect_arrives_then_move_to_disconnected() {
        val stateMachine = CallStateMachine()
        val allStates = listOf(
            CallState.Idle,
            CallState.Dialing,
            CallState.Active,
            CallState.Holding,
            CallState.Disconnected
        )
        allStates.forEach {
            val nextState = stateMachine.transition(
                currentState = it,
                event = CallEvent.Disconnect
            )

            assertEquals(CallState.Disconnected, nextState)
        }
    }

    @Test
    fun given_disconnected_when_any_event_arrives_then_keep_disconnected() {
        val stateMachine = CallStateMachine()
        CallEvent.entries.forEach {
            val nextState = stateMachine.transition(
                currentState = CallState.Disconnected,
                event = it
            )

            assertEquals("event=$it", CallState.Disconnected, nextState)
        }
    }

    @Test
    fun given_non_terminal_state_when_invalid_event_arrives_then_keep_current_state() {
        val stateMachine = CallStateMachine()
        val invalidTransition = listOf(
            CallState.Idle to CallEvent.Connected,
            CallState.Idle to CallEvent.Hold,
            CallState.Idle to CallEvent.Resume,
            CallState.Dialing to CallEvent.StartOutgoing,
            CallState.Dialing to CallEvent.Hold,
            CallState.Dialing to CallEvent.Resume,
            CallState.Active to CallEvent.StartOutgoing,
            CallState.Active to CallEvent.Connected,
            CallState.Active to CallEvent.Resume,
            CallState.Holding to CallEvent.StartOutgoing,
            CallState.Holding to CallEvent.Connected,
            CallState.Holding to CallEvent.Hold,
        )
        invalidTransition.forEach { (currentState, event) ->
            val nextState = stateMachine.transition(
                currentState = currentState,
                event = event
            )

            assertEquals(
                "currentState=$currentState, event=$event",
                currentState,
                nextState
            )
        }
    }
}
