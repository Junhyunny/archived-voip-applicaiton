package com.example.myapplication.feature.call

import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class CallStatusActivity : AppCompatActivity() {
    override fun onCreate(
        savedInstanceState: Bundle?,
    ) {
        super.onCreate(savedInstanceState)

        val statusText = TextView(this).apply {
            text = "종료됨"
            gravity = Gravity.CENTER
        }
        val lastEventText = TextView(this).apply {
            text = "마지막 이벤트: 없음"
            gravity = Gravity.CENTER
        }
        val lateConnectedButton = Button(this).apply {
            text = "늦은 Connected 전달"
            setOnClickListener {
                lastEventText.text = "마지막 이벤트: Connected"
                statusText.text = "종료됨"
            }
        }
        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                addView(statusText)
                addView(lastEventText)
                addView(lateConnectedButton)
            }
        )
    }
}
