package com.example.voip.mocks

import com.example.voip.utils.CountdownTicker
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow

class FakeCountdownTicker : CountdownTicker {

    private val flows =
        mutableListOf<MutableSharedFlow<Long>>()
    var startCount = 0

    override fun start(
        durationMillis: Long
    ): Flow<Long> {
        startCount++
        return MutableSharedFlow<Long>().also {
            flows += it
        }
    }

    fun flow(index: Int): MutableSharedFlow<Long> {
        return flows[index]
    }
}