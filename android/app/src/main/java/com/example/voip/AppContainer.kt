package com.example.voip

import com.example.voip.utils.AndroidMonotonicClock
import com.example.voip.utils.CountdownTicker
import com.example.voip.utils.CountdownTickerImpl

interface AppContainer {
    val countdownTicker: CountdownTicker
}

class DefaultAppContainer : AppContainer {
    override val countdownTicker: CountdownTicker by lazy {
        CountdownTickerImpl(
            AndroidMonotonicClock
        )
    }
}