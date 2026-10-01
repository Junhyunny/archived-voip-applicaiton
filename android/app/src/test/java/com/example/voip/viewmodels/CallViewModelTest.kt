package com.example.voip.viewmodels

import com.example.voip.mocks.TestMonotonicClock
import com.example.voip.utils.CountdownTicker
import com.example.voip.utils.CountdownTickerImpl
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TestWatcher
import org.junit.runner.Description
import kotlin.time.Duration.Companion.milliseconds

@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(
    val testDispatcher: TestDispatcher = StandardTestDispatcher(),
) : TestWatcher() {

    override fun starting(description: Description) {
        Dispatchers.setMain(
            testDispatcher
        )
    }

    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}

class FakeCountdownTicker : CountdownTicker {

    private val flows =
        mutableListOf<MutableSharedFlow<Long>>()

    override fun start(
        durationMillis: Long
    ): Flow<Long> {
        return MutableSharedFlow<Long>().also {
            flows += it
        }
    }

    fun flow(index: Int): MutableSharedFlow<Long> {
        return flows[index]
    }
}

@OptIn(ExperimentalCoroutinesApi::class)
class CallViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun when_start_timer_then_remain_time_ui_state_is_duration_time() = runTest(
        mainDispatcherRule.testDispatcher
    ) {
        val testClock = TestMonotonicClock(
            testScheduler
        )
        val timer = CountdownTickerImpl(testClock)
        val sut = CallViewModel(countdownTicker = timer)

        sut.startTimer(durationMillis = 3_000L)

        runCurrent()

        assertEquals(
            3L,
            sut.uiState.value.remainSeconds
        )
    }

    @Test
    fun given_timer_is_started_when_one_second_is_passed_then_remain_time_ui_state_is_down_by_one_second() =
        runTest(
            mainDispatcherRule.testDispatcher
        ) {
            val testClock = TestMonotonicClock(
                testScheduler
            )
            val timer = CountdownTickerImpl(testClock)
            val sut = CallViewModel(countdownTicker = timer)
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
    fun when_timer_is_started_two_times_then_previous_timer_is_cancelled() =
        runTest(mainDispatcherRule.testDispatcher) {
            val timer = FakeCountdownTicker()
            val sut = CallViewModel(timer)

            sut.startTimer(3_000L)
            runCurrent()

            val firstTimer = timer.flow(0)
            firstTimer.emit(3_000L)
            runCurrent()

            assertEquals(
                3L,
                sut.uiState.value.remainSeconds
            )

            sut.startTimer(10_000L)
            runCurrent()

            val secondTimer = timer.flow(1)
            secondTimer.emit(10_000L)
            runCurrent()

            assertEquals(
                10L,
                sut.uiState.value.remainSeconds
            )

            firstTimer.emit(1_000L)
            runCurrent()

            assertEquals(
                10L,
                sut.uiState.value.remainSeconds
            )

            secondTimer.emit(9_000L)
            runCurrent()

            assertEquals(
                9L,
                sut.uiState.value.remainSeconds
            )
        }
}