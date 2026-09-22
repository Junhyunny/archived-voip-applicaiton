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

class MainActivityTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun when_render_then_see_text_information() {
        composeTestRule.onNodeWithText("방코드").assertIsDisplayed()
        composeTestRule.onNodeWithText("두 기기에 같은 코드를 입력하세요").assertIsDisplayed()
    }

    @Test
    fun when_render_then_see_entered_room_code_field_for_4_digits() {
        composeTestRule.onNodeWithTag("room_code_digit_0").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_1").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_2").assertExists().assertTextEquals("")
        composeTestRule.onNodeWithTag("room_code_digit_3").assertExists().assertTextEquals("")
    }

    @Test
    fun when_render_then_see_keypad() {
        val buttonRole = SemanticsMatcher.expectValue(
            SemanticsProperties.Role, Role.Button
        )
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (index in 0..9) {
            val numberInKeypad = hasText("$index") and buttonRole and keypad
            composeTestRule.onNode(numberInKeypad).assertIsDisplayed()
        }
        val deleteButton = hasText("delete") and buttonRole and keypad
        composeTestRule.onNode(deleteButton).assertIsDisplayed()
    }

    @Test
    fun when_render_then_see_call_start_button() {
        val buttonRole = SemanticsMatcher.expectValue(
            SemanticsProperties.Role, Role.Button
        )

        val callStartButton = composeTestRule.onNode(hasText("통화 시작") and buttonRole)
        callStartButton.isDisplayed()
        callStartButton.assertIsNotEnabled()
    }

    @Test
    fun given_render_when_click_4_digits_then_call_start_button_is_enabled() {
        val buttonRole = SemanticsMatcher.expectValue(
            SemanticsProperties.Role, Role.Button
        )
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        val tc = listOf("1", "2", "3", "4")
        for (buttonNumber in tc) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        val callStartButton = composeTestRule.onNode(hasText("통화 시작") and buttonRole)
        callStartButton.assertIsEnabled()
    }
}
