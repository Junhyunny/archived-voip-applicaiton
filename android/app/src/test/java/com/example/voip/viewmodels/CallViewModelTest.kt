package com.example.voip.viewmodels

import com.example.voip.clients.SignalClient
import com.example.voip.mocks.FakeCountdownTicker
import com.example.voip.mocks.MainDispatcherRule
import com.example.voip.mocks.TestMonotonicClock
import com.example.voip.types.CallStatus
import com.example.voip.types.SignalEvent
import com.example.voip.utils.CountdownTickerImpl
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import kotlin.time.Duration.Companion.milliseconds


@OptIn(ExperimentalCoroutinesApi::class)
class CallViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    lateinit var fakeCountdownTicker: FakeCountdownTicker
    lateinit var mockSignalClient: SignalClient

    @Before
    fun setup() {
        fakeCountdownTicker = FakeCountdownTicker()
        mockSignalClient = mockk(relaxed = true)
    }

    @Test
    fun when_start_timer_then_remain_time_is_duration_time() = runTest(
        mainDispatcherRule.testDispatcher
    ) {
        val testClock = TestMonotonicClock(testScheduler)
        val timer = CountdownTickerImpl(testClock)
        val sut = CallViewModel(timer, mockSignalClient)

        sut.startTimer(durationMillis = 3_000L)

        runCurrent()

        assertEquals(
            3L,
            sut.uiState.value.remainSeconds
        )
    }

    @Test
    fun given_timer_is_started_when_one_second_is_passed_then_remain_time_is_down_by_one_second() =
        runTest(
            mainDispatcherRule.testDispatcher
        ) {
            val testClock = TestMonotonicClock(testScheduler)
            val timer = CountdownTickerImpl(testClock)
            val sut = CallViewModel(timer, mockSignalClient)
            sut.startTimer(durationMillis = 3_000L)

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                2L,
                sut.uiState.value.remainSeconds
            )

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                1L,
                sut.uiState.value.remainSeconds
            )

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                0L,
                sut.uiState.value.remainSeconds
            )
        }

    @Test
    fun given_timer_is_started_when_one_second_is_passed_then_isCountdownFinished_flag_becomes_true() =
        runTest(
            mainDispatcherRule.testDispatcher
        ) {
            val testClock = TestMonotonicClock(testScheduler)
            val timer = CountdownTickerImpl(testClock)
            val sut = CallViewModel(timer, mockSignalClient)
            sut.startTimer(durationMillis = 3_000L)
            assertFalse(
                sut.uiState.value.isCountdownFinished
            )

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertFalse(
                sut.uiState.value.isCountdownFinished
            )

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertFalse(
                sut.uiState.value.isCountdownFinished
            )

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertTrue(
                sut.uiState.value.isCountdownFinished
            )
        }

    @Test
    fun when_timer_is_started_two_times_then_new_timer_is_not_started() =
        runTest(mainDispatcherRule.testDispatcher) {
            val sut = CallViewModel(fakeCountdownTicker, mockSignalClient)

            sut.startTimer(3_000L)
            runCurrent()

            val firstTimer = fakeCountdownTicker.flow(0)
            firstTimer.emit(3_000L)
            runCurrent()

            assertEquals(
                3L,
                sut.uiState.value.remainSeconds
            )

            sut.startTimer(10_000L)
            runCurrent()

            assertEquals(1, fakeCountdownTicker.startCount)
        }

    @Test
    fun when_view_model_is_initialized_then_call_status_is_UNCONNECTED() {
        val sut =
            CallViewModel(fakeCountdownTicker, mockSignalClient)


        assertEquals(
            CallStatus.UNCONNECTED,
            sut.uiState.value.callStatus
        )
    }

    @Test
    fun when_start_call_then_signal_client_connect_and_join_is_called() = runTest {
        val sut =
            CallViewModel(fakeCountdownTicker, mockSignalClient)

        sut.startCall("1234")
        advanceUntilIdle()

        coVerify(exactly = 1) { mockSignalClient.connect() }
        verify(exactly = 1) { mockSignalClient.join("1234") }
    }

    @Test
    fun given_call_is_started_already_when_start_call_again_then_signal_client_connect_and_join_is_not_called_two_times() =
        runTest {
            val sut =
                CallViewModel(fakeCountdownTicker, mockSignalClient)

            sut.startCall("1234")
            advanceUntilIdle()

            sut.startCall("1234")
            advanceUntilIdle()

            coVerify(exactly = 1) { mockSignalClient.connect() }
            verify(exactly = 1) { mockSignalClient.join("1234") }
        }

    @Test
    fun when_connect_throws_exception_then_ui_status_is_changed_to_disconnected() = runTest {
        coEvery { mockSignalClient.connect() } throws RuntimeException()
        val sut =
            CallViewModel(fakeCountdownTicker, mockSignalClient)

        sut.startCall("1234")
        advanceUntilIdle()

        assertEquals(
            CallStatus.DISCONNECTED,
            sut.uiState.value.callStatus
        )
    }

    @Test
    fun when_join_throws_exception_then_ui_status_is_changed_to_disconnected() = runTest {
        coEvery { mockSignalClient.join(any()) } throws RuntimeException()
        val sut =
            CallViewModel(fakeCountdownTicker, mockSignalClient)

        sut.startCall("1234")
        advanceUntilIdle()

        assertEquals(
            CallStatus.DISCONNECTED,
            sut.uiState.value.callStatus
        )
    }

    @Test
    fun when_start_call_then_events_from_signal_client_is_observed() = runTest {
        val events = Channel<SignalEvent>(Channel.BUFFERED)
        every { mockSignalClient.events } returns events.receiveAsFlow()
        val sut =
            CallViewModel(fakeCountdownTicker, mockSignalClient)
        sut.startCall("1234")
        advanceUntilIdle()

        val testCases = listOf(
            Pair(SignalEvent.Connected, CallStatus.IDLE),
            Pair(SignalEvent.Joined, CallStatus.JOINED),
            Pair(SignalEvent.JoinFailed, CallStatus.DISCONNECTED),
            Pair(SignalEvent.PeerLeft, CallStatus.DISCONNECTED),
            Pair(SignalEvent.Disconnected, CallStatus.DISCONNECTED),
            Pair(SignalEvent.PeerJoined, CallStatus.NEGOTIATING),
            Pair(SignalEvent.Offer, CallStatus.NEGOTIATING),
        )
        for ((first, second) in testCases) {
            events.send(first)
            advanceUntilIdle()

            assertEquals(
                second,
                sut.uiState.value.callStatus
            )
        }
    }
}