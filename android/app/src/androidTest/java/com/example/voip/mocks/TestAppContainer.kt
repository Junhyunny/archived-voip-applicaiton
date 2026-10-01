package com.example.voip.mocks

import com.example.voip.AppContainer

class TestAppContainer : AppContainer {
    override val countdownTicker: FakeCountdownTicker = FakeCountdownTicker()
}