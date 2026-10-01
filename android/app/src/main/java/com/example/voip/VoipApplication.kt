package com.example.voip

import android.app.Application

class VoipApplication : Application() {
    val appContainer: AppContainer by lazy { DefaultAppContainer() }
}