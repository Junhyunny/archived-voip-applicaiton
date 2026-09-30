package com.example.voip

import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.hasAnyAncestor
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.isDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Rule
import org.junit.Test

class MainActivityTests {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()
    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )

    @Test
    fun when_render_then_heading_and_description_are_shown() {
        composeTestRule.onNodeWithText("방코드").assertIsDisplayed()
        composeTestRule.onNodeWithText("두 기기에 같은 코드를 입력하세요").assertIsDisplayed()
    }

    @Test
    fun when_render_then_room_code_input_fields_for_4_digits_are_shown() {
        composeTestRule.onNodeWithTag("room_code_digit_0").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_1").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_2").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_3").assertExists().assertTextEquals("")
    }

    @Test
    fun when_render_then_number_keypad_is_shown() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (index in 0..9) {
            val numberInKeypad = hasText("$index") and buttonRole and keypad
            composeTestRule.onNode(numberInKeypad).assertIsDisplayed()
        }
        val deleteButton = hasText("delete") and buttonRole and keypad
        composeTestRule.onNode(deleteButton).assertIsDisplayed()
    }

    @Test
    fun when_render_then_call_start_button_is_shown_and_disabled() {
        val callStartButton = composeTestRule.onNode(hasText("통화 시작") and buttonRole)
        callStartButton.isDisplayed()
        callStartButton.assertIsNotEnabled()
    }

    @Test
    fun given_render_when_press_4_digits_then_call_start_button_is_enabled() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        val numbers = listOf("1", "2", "3", "4")
        for (buttonNumber in numbers) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        val callStartButton = composeTestRule.onNode(hasText("통화 시작") and buttonRole)
        callStartButton.assertIsEnabled()
    }

    @Test
    fun given_render_when_press_more_than_4_digits_then_call_start_button_is_enabled() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        val numbers = listOf("1", "2", "3", "4", "5")
        for (buttonNumber in numbers) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        val callStartButton = composeTestRule.onNode(hasText("통화 시작") and buttonRole)
        callStartButton.assertIsEnabled()
    }
}
