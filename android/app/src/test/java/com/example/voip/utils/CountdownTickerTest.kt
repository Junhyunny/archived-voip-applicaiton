package com.example.voip.utils

import com.example.voip.mocks.TestMonotonicClock
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Test
import kotlin.time.Duration.Companion.milliseconds

@OptIn(ExperimentalCoroutinesApi::class)
class CountdownTickerTest {

    @Test
    fun when_start_then_duration_time_is_emitted() = runTest {
        val sut = CountdownTickerImpl(
            TestMonotonicClock(testScheduler)
        )
        val values = mutableListOf<Long>()

        backgroundScope.launch {
            sut.start(3_000L)
                .toList(values)
        }

        runCurrent()

        assertEquals(
            listOf(3_000L),
            values
        )
    }

    @Test
    fun given_timer_is_started_with_three_seconds_duration_when_one_second_is_passed_then_two_seconds_emitted() =
        runTest {
            val sut = CountdownTickerImpl(
                TestMonotonicClock(testScheduler)
            )
            val values = mutableListOf<Long>()
            backgroundScope.launch {
                sut.start(3_000L)
                    .toList(values)
            }

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                listOf(3_000L, 2_000L),
                values
            )
        }

    @Test
    fun given_timer_is_started_with_one_second_duration_when_one_second_is_passed_then_zero_is_emitted_and_timer_is_finished() =
        runTest {
            val sut = CountdownTickerImpl(
                TestMonotonicClock(testScheduler)
            )
            val values = mutableListOf<Long>()
            backgroundScope.launch {
                sut.start(1_000L)
                    .toList(values)
            }

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                listOf(1_000L, 0L),
                values
            )


            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                listOf(1_000L, 0L),
                values
            )
        }

    @Test
    fun given_timer_is_started_with_0_point_5_second_when_one_second_is_passed_then_zero_is_emitted() =
        runTest {
            val sut = CountdownTickerImpl(
                TestMonotonicClock(testScheduler)
            )
            val values = mutableListOf<Long>()
            backgroundScope.launch {
                sut.start(500L)
                    .toList(values)
            }

            advanceTimeBy(1_000L.milliseconds)
            runCurrent()

            assertEquals(
                listOf(500L, 0L),
                values
            )
        }
}