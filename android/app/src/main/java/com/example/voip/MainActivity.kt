package com.example.voip

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.example.voip.routes.AppNavHost
import com.example.voip.screens.EnterRoomScreen
import com.example.voip.ui.theme.VoipandroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val appContainer = DefaultAppContainer()
        setContent {
            VoipandroidTheme {
                AppNavHost(appContainer = appContainer)
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    VoipandroidTheme {
        EnterRoomScreen({})
    }
}