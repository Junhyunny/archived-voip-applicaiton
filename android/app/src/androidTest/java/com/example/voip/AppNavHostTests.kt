package com.example.voip

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
import com.example.voip.routes.AppNavHost
import com.example.voip.routes.CallRoute
import com.example.voip.routes.EnterRoomRoute
import junit.framework.TestCase.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AppNavHostTests {

    @get:Rule
    val composeTestRule = createComposeRule()

    private lateinit var navController: TestNavHostController

    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )

    @Before
    fun setup() {
        composeTestRule.setContent {
            navController = TestNavHostController(LocalContext.current).apply {
                navigatorProvider.addNavigator(ComposeNavigator())
            }
            AppNavHost(navController = navController)
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
}