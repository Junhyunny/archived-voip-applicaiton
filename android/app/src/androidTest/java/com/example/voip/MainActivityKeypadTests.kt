package com.example.voip

import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.hasAnyAncestor
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized

@RunWith(Parameterized::class)
class MainActivityKeypadTests(
    private val tc: List<String>
) {
    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    val buttonRole = SemanticsMatcher.expectValue(
        SemanticsProperties.Role, Role.Button
    )

    @Test
    fun given_render_when_click_4_digits_then_4_digits_are_shown_in_digit_section() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (buttonNumber in tc) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        for (index in 0..<4) {
            composeTestRule.onNodeWithTag("room_code_digit_$index")
                .assertExists()
                .assertTextEquals(tc[index])
        }
    }

    @Test
    fun given_press_digits_when_press_delete_then_last_digit_is_deleted() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (buttonNumber in tc) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        composeTestRule.onNode(
            hasText("delete") and buttonRole and keypad
        ).performClick()

        for (index in 0..<3) {
            composeTestRule.onNodeWithTag("room_code_digit_$index")
                .assertExists()
                .assertTextEquals(tc[index])
        }
        composeTestRule.onNodeWithTag("room_code_digit_3")
            .assertExists()
            .assertTextEquals("")
    }

    @Test
    fun given_press_digits_when_press_delete_more_than_input_then_all_digits_are_deleted() {
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (buttonNumber in tc) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }

        repeat(5) {
            composeTestRule.onNode(
                hasText("delete") and buttonRole and keypad
            ).performClick()
        }

        for (index in 0..<4) {
            composeTestRule.onNodeWithTag("room_code_digit_$index")
                .assertExists()
                .assertTextEquals("")
        }
    }

    companion object {
        @JvmStatic
        @Parameterized.Parameters(name = "{index}")
        fun data() = listOf(
            listOf("1", "2", "3", "4"),
            listOf("5", "6", "7", "8"),
            listOf("9", "0", "3", "4"),
        )
    }
}