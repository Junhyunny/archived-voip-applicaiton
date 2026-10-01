package com.example.voip.utils

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlin.time.Duration.Companion.milliseconds

interface CountdownTicker {
    fun start(
        durationMillis: Long
    ): Flow<Long>
}

class CountdownTickerImpl(
    private val clock: MonotonicClock
) : CountdownTicker {
    override fun start(durationMillis: Long): Flow<Long> {
        return flow {
            val endTime = clock.nowMillis() + durationMillis
            while (true) {
                val remainTime = (endTime - clock.nowMillis()).coerceAtLeast(0L)
                emit(remainTime)
                if (remainTime == 0L) {
                    break
                }
                delay(1_000L.milliseconds)
            }
        }
    }
}