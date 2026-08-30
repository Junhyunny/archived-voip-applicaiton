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

    // TODO(Day 01 - next outside-in slice): CallStateMachine을 Activity에 연결하기 전에 화면 Red를 먼저 추가한다.
    // Given: 상태 시뮬레이터 화면이 Idle 상태로 열린다.
    // When: 사용자가 StartOutgoing 이벤트를 전달한다.
    // Then: 화면에 "발신 중"이 표시된다.
    // And: Connected -> "통화 중", Hold -> "보류 중", Resume -> "통화 중", Disconnect -> "종료됨"을 화면에서 검증한다.
    // And: 종료 후 늦은 Connected를 전달해도 계속 "종료됨"인지 검증한다.
    // 구현을 교체하기 전에 이 acceptance test가 현재 Activity에서 의도대로 실패하는지 확인한다.
}
