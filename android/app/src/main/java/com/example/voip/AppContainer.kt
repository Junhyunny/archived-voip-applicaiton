package com.example.voip

import com.example.voip.clients.SignalClient
import com.example.voip.clients.SignalClientImpl
import com.example.voip.utils.AndroidMonotonicClock
import com.example.voip.utils.CountdownTicker
import com.example.voip.utils.CountdownTickerImpl
import com.example.voip.viewmodels.CallViewModel
import okhttp3.OkHttpClient

interface AppContainer {
    fun createCallViewModel(): CallViewModel
}

class DefaultAppContainer : AppContainer {
    private val countdownTicker: CountdownTicker by lazy {
        CountdownTickerImpl(
            AndroidMonotonicClock
        )
    }
    private val okHttpClient: OkHttpClient by lazy {
        OkHttpClient()
    }

    private fun createSignalClient(): SignalClient =
        SignalClientImpl(
            "${BuildConfig.WEB_SOCKET_BASE_URL}/signaling",
            okHttpClient
        )

    override fun createCallViewModel(): CallViewModel = CallViewModel(
        countdownTicker,
        createSignalClient()
    )
}