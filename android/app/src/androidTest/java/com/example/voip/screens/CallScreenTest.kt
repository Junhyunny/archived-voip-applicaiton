package com.example.voip.screens

import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertIsOff
import androidx.compose.ui.test.assertIsOn
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.voip.clients.SignalClient
import com.example.voip.mocks.FakeCountdownTicker
import com.example.voip.types.CallStatus
import com.example.voip.types.SignalEvent
import com.example.voip.viewmodels.CallUiState
import com.example.voip.viewmodels.CallViewModel
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test

class CallScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()
    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )
    val checkboxRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Checkbox
    )
    lateinit var mockSignalClient: SignalClient

    @Before
    fun setup() {
        mockSignalClient = mockk(relaxed = true)
    }

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
        composeTestRule.onNode(
            hasTestTag("joined") and checkboxRole
        ).assertExists().assertIsOff()
        composeTestRule.onNode(hasText("시그널링 서버 연결")).assertExists()
        composeTestRule.onNode(
            hasTestTag("peer_joined") and checkboxRole
        ).assertExists().assertIsOff()
        composeTestRule.onNode(hasText("상대방 입장")).assertExists()
        composeTestRule.onNode(hasText("60초 후 자동 종료")).assertExists()
        composeTestRule.onNode(hasText("취소") and buttonRole).assertExists()
    }

    @Test
    fun when_render_then_count_down_is_started() {
        val timer = FakeCountdownTicker()
        composeTestRule.setContent {
            CallScreen(viewModel { CallViewModel(timer, mockSignalClient) }, "1234", 6_000L, {})
        }
        composeTestRule.waitForIdle()

        composeTestRule.onNode(hasText("6초 후 자동 종료")).assertExists()

        timer.emit(5_000L)

        composeTestRule.waitForIdle()

        composeTestRule.onNode(hasText("5초 후 자동 종료")).assertExists()
    }

    @Test
    fun when_countdown_is_finished_then_move_back_is_called() {
        val spyMoveBack = mockk<() -> Unit>(relaxed = true)
        val timer = FakeCountdownTicker()
        composeTestRule.setContent {
            CallScreen(
                viewModel { CallViewModel(timer, mockSignalClient) },
                "1234",
                1_000L,
                spyMoveBack
            )
        }
        composeTestRule.waitForIdle()

        timer.emit(0L)

        composeTestRule.waitForIdle()

        verify(exactly = 1) { spyMoveBack() }
    }

    @Test
    fun when_call_status_is_JOINED_then_server_connected_checkbox_is_checked() {
        val status = CallUiState(callStatus = CallStatus.JOINED)
        composeTestRule.setContent {
            CallScreenContent("1234", uiState = status)
        }

        composeTestRule.onNode(
            hasTestTag("joined") and checkboxRole
        ).assertExists().assertIsOn()
    }

    @Test
    fun when_call_status_is_NEGOTIATING_then_server_connected_and_peer_joined_checkbox_is_checked() {
        val status = CallUiState(callStatus = CallStatus.NEGOTIATING)
        composeTestRule.setContent {
            CallScreenContent("1234", uiState = status)
        }

        composeTestRule.onNode(
            hasTestTag("joined") and checkboxRole
        ).assertExists().assertIsOn()
        composeTestRule.onNode(
            hasTestTag("peer_joined") and checkboxRole
        ).assertExists().assertIsOn()
    }

    @Test
    fun when_call_status_is_CONNECTED_then_connected_information_is_shown() {
        val status = CallUiState(callStatus = CallStatus.CONNECTED)
        composeTestRule.setContent {
            CallScreenContent("1234", uiState = status)
        }

        composeTestRule.onNode(hasText("연결됨 · P2P")).assertExists()
        composeTestRule.onNode(hasText("1234")).assertExists()
        composeTestRule.onNode(hasText("방 코드 1234 로 통화 중")).assertExists()
        composeTestRule.onNode(hasText("AI가 통화를 듣고 있어요")).assertExists()
        composeTestRule.onNode(hasText("자막은 표시하지 않습니다. 통화가 끝나면 요약이 만들어집니다.")).assertExists()
        composeTestRule.onNode(hasText("통화 종료") and buttonRole).assertExists()
    }

    @Test
    fun when_call_status_is_DISCONNECTED_then_move_back_is_called() = runTest {
        val events = Channel<SignalEvent>(Channel.BUFFERED)
        every { mockSignalClient.events } returns events.receiveAsFlow()
        val spyMoveBack = mockk<() -> Unit>(relaxed = true)
        composeTestRule.setContent {
            CallScreen(
                viewModel { CallViewModel(FakeCountdownTicker(), mockSignalClient) },
                "1234",
                60_000L,
                spyMoveBack
            )
        }

        events.send(SignalEvent.Disconnected)
        composeTestRule.waitForIdle()

        verify(exactly = 1) { spyMoveBack() }
    }
}