package com.example.voip.viewmodels

import com.example.voip.mocks.FakeCountdownTicker
import com.example.voip.mocks.MainDispatcherRule
import com.example.voip.mocks.TestMonotonicClock
import com.example.voip.utils.CountdownTickerImpl
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import kotlin.time.Duration.Companion.milliseconds


@OptIn(ExperimentalCoroutinesApi::class)
class CallViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun when_start_timer_then_remain_time_is_duration_time() = runTest(
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
    fun given_timer_is_started_when_one_second_is_passed_then_remain_time_is_down_by_one_second() =
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
    fun given_timer_is_started_when_one_second_is_passed_then_isCountdownFinished_flag_becomes_true() =
        runTest(
            mainDispatcherRule.testDispatcher
        ) {
            val testClock = TestMonotonicClock(
                testScheduler
            )
            val timer = CountdownTickerImpl(testClock)
            val sut = CallViewModel(countdownTicker = timer)
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

            assertEquals(1, timer.startCount)
        }
}