package com.example.voip.routes

import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.compose.ComposeNavigator
import androidx.navigation.testing.TestNavHostController
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.voip.mocks.TestAppContainer
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AppNavHostTests {

    @get:Rule
    val composeTestRule = createComposeRule()

    private lateinit var navController: TestNavHostController
    private lateinit var testAppContainer: TestAppContainer

    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )

    @Before
    fun setup() {
        testAppContainer = TestAppContainer()
        composeTestRule.setContent {
            navController = TestNavHostController(LocalContext.current).apply {
                navigatorProvider.addNavigator(ComposeNavigator())
            }
            AppNavHost(navController = navController, appContainer = testAppContainer)
        }
    }

    @Test
    fun when_render_then_default_route_is_enter_room_screen() {
        assertTrue(navController.currentDestination?.hasRoute<EnterRoomRoute>() == true)
    }

    @Test
    fun when_enter_digits_click_call_start_button_then_call_screen_is_shown() {
        composeTestRule.onNode(hasText("1") and buttonRole).performClick()
        composeTestRule.onNode(hasText("2") and buttonRole).performClick()
        composeTestRule.onNode(hasText("3") and buttonRole).performClick()
        composeTestRule.onNode(hasText("4") and buttonRole).performClick()

        composeTestRule.onNodeWithText("통화 시작").performClick()

        assertTrue(navController.currentDestination?.hasRoute<CallRoute>() == true)
        composeTestRule.onNode(hasText("1234")).assertExists()
    }

    @Test
    fun given_call_screen_is_shown_when_count_down_is_finished_then_screen_is_back_to_enter_room_screen() {
        composeTestRule.onNode(hasText("1") and buttonRole).performClick()
        composeTestRule.onNode(hasText("2") and buttonRole).performClick()
        composeTestRule.onNode(hasText("3") and buttonRole).performClick()
        composeTestRule.onNode(hasText("4") and buttonRole).performClick()
        composeTestRule.onNodeWithText("통화 시작").performClick()
        assertTrue(navController.currentDestination?.hasRoute<CallRoute>() == true)

        composeTestRule.waitUntil {
            testAppContainer.countdownTicker.subscriptionCount.value == 1
        }

        testAppContainer.countdownTicker.emit(0)

        composeTestRule.waitUntil(timeoutMillis = 1_000L) {
            navController.currentDestination
                ?.hasRoute<EnterRoomRoute>() == true
        }
    }
}