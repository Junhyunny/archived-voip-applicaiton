package com.example.myapplication.feature.call

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
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

    @Test
    fun given_closed_call_when_late_connected_arrives_then_keep_closed_status() {
        onView(withText("종료됨"))
            .check(matches(isDisplayed()))

        onView(withText("늦은 Connected 전달"))
            .perform(click())

        onView(withText("마지막 이벤트: Connected"))
            .check(matches(isDisplayed()))
        onView(withText("종료됨"))
            .check(matches(isDisplayed()))
    }
}
