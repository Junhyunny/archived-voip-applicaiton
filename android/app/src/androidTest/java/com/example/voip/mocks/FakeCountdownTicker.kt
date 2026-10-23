package com.example.voip.mocks

import com.example.voip.utils.CountdownTicker
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

class FakeCountdownTicker : CountdownTicker {

    private val _flow =
        MutableStateFlow(0L)
    val subscriptionCount get() = _flow.subscriptionCount

    override fun start(
        durationMillis: Long
    ): Flow<Long> {
        _flow.value = durationMillis
        return _flow
    }

    fun emit(
        remainTime: Long
    ) {
        _flow.value = remainTime
    }
}
