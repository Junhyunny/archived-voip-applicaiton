package com.example.voip.mocks

import com.example.voip.utils.MonotonicClock
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestCoroutineScheduler

@OptIn(ExperimentalCoroutinesApi::class)
class TestMonotonicClock(private val scheduler: TestCoroutineScheduler) : MonotonicClock {
    override fun nowMillis(): Long {
        return scheduler.currentTime
    }
}