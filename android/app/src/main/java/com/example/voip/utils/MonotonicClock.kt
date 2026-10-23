package com.example.voip.utils

import android.os.SystemClock

interface MonotonicClock {
    fun nowMillis(): Long
}

object AndroidMonotonicClock : MonotonicClock {
    override fun nowMillis(): Long {
        return SystemClock.elapsedRealtime()
    }
}