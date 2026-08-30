package com.example.myapplication.feature.call

import android.os.Bundle
import android.view.Gravity
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class CallStatusActivity : AppCompatActivity() {
    override fun onCreate(
        savedInstanceState: Bundle?,
    ) {
        super.onCreate(savedInstanceState)
        setContentView(
            TextView(this).apply {
                text = "종료됨"
                gravity = Gravity.CENTER
            }
        )
    }
}
