package com.example.voip.mocks

import com.example.voip.AppContainer
import com.example.voip.clients.SignalClient
import com.example.voip.viewmodels.CallViewModel
import io.mockk.mockk

class TestAppContainer : AppContainer {
    var countdownTicker: FakeCountdownTicker = FakeCountdownTicker()
    var signalClient: SignalClient = mockk(relaxed = true)

    override fun createCallViewModel(): CallViewModel =
        CallViewModel(countdownTicker, signalClient)
}