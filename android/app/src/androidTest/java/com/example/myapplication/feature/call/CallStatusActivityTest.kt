package com.example.myapplication.feature.call

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class CallStatusActivityTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(CallStatusActivity::class.java)

    @Test
    fun when_user_open_the_screen_then_see_closed_phone_call() {
        onView(withText("종료됨"))
            .check(matches(isDisplayed()))
    }
}
