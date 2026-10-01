package com.example.voip.screens

import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.voip.utils.CountdownTicker
import com.example.voip.viewmodels.CallUiState
import com.example.voip.viewmodels.CallViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.runBlocking
import org.junit.Rule
import org.junit.Test

class FakeCountdownTicker : CountdownTicker {

    private val _flow =
        MutableStateFlow(0L)

    override fun start(
        durationMillis: Long
    ): Flow<Long> {
        _flow.value = durationMillis
        return _flow
    }

    fun emit(
        remainTime: Long
    ) {
        _flow.value = remainTime
    }
}

class CallScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()
    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )

    @Test
    fun when_render_then_call_status_information_is_shown() {
        composeTestRule.setContent {
            CallScreenContent("1234", uiState = CallUiState(remainSeconds = 60))
        }

        composeTestRule.onNode(hasText("연결중")).assertExists()
        composeTestRule.onNode(hasText("1234")).assertExists()
        composeTestRule.onNode(hasText("상대방이 입장했어요")).assertExists()
        composeTestRule.onNode(hasText("음성을 연결하고 있어요")).assertExists()
        composeTestRule.onNode(hasText("잠시 후 통화 화면으로 이동합니다")).assertExists()
        composeTestRule.onNode(hasText("시그널링 서버 연결")).assertExists()
        composeTestRule.onNode(hasText("상대방 입장")).assertExists()
        composeTestRule.onNode(hasText("60초 후 자동 종료")).assertExists()
        composeTestRule.onNode(hasText("취소") and buttonRole).assertExists()
    }

    @Test
    fun when_render_then_count_down_is_started() {
        val timer = FakeCountdownTicker()
        composeTestRule.setContent {
            CallScreen(viewModel { CallViewModel(timer) }, "1234", 6_000L)
        }
        composeTestRule.waitForIdle()

        composeTestRule.onNode(hasText("6초 후 자동 종료")).assertExists()

        runBlocking {
            timer.emit(5_000L)
        }

        composeTestRule.waitForIdle()

        composeTestRule.onNode(hasText("5초 후 자동 종료")).assertExists()
    }
}