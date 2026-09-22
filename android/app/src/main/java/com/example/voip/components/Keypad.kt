package com.example.voip.components

import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag

enum class KeypadKey(val label: String) {
    One("1"), Two("2"), Three("3"),
    Four("4"), Five("5"), Six("6"),
    Seven("7"), Eight("8"), Nine("9"),
    Empty(""), Zero("0"), Delete("delete"),
}

val keypad = listOf(
    KeypadKey.One, KeypadKey.Two, KeypadKey.Three,
    KeypadKey.Four, KeypadKey.Five, KeypadKey.Six,
    KeypadKey.Seven, KeypadKey.Eight, KeypadKey.Nine,
    KeypadKey.Empty, KeypadKey.Zero, KeypadKey.Delete,
)

@Composable
fun Keypad(onKeyPress: (KeypadKey) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(3),
        modifier = Modifier.testTag("keypad")
    ) {
        items(keypad) { item ->
            Button(modifier = Modifier, onClick = { onKeyPress(item) }) { Text(item.label) }
        }
    }
}