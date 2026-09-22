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

    @Test
    fun given_render_when_click_4_digits_then_see_4_digits_in_digit_section() {
        val buttonRole = SemanticsMatcher.expectValue(
            SemanticsProperties.Role, Role.Button
        )
        val keypad = hasAnyAncestor(hasTestTag("keypad"))
        for (buttonNumber in tc) {
            composeTestRule.onNode(
                hasText(buttonNumber) and buttonRole and keypad
            ).performClick()
        }
        composeTestRule.onNodeWithTag("room_code_digit_0")
            .assertExists()
            .assertTextEquals(tc[0])
        composeTestRule.onNodeWithTag("room_code_digit_1")
            .assertExists()
            .assertTextEquals(tc[1])
        composeTestRule.onNodeWithTag("room_code_digit_2")
            .assertExists()
            .assertTextEquals(tc[2])
        composeTestRule.onNodeWithTag("room_code_digit_3")
            .assertExists()
            .assertTextEquals(tc[3])
    }

    companion object {
        @JvmStatic
        @Parameterized.Parameters(name = "input={0}")
        fun data() = listOf(
            arrayOf(listOf("1", "2", "3", "4")),
            arrayOf(listOf("5", "6", "7", "8")),
            arrayOf(listOf("9", "0", "3", "4")),
        )
    }
}