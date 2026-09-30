//
//  EnterRoomViewUITests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import XCTest

final class EnterRoomViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_when_render_then_number_keypad_is_shown() throws {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        XCTAssertTrue(keypad.waitForExistence(timeout: 2))
    }

    @MainActor
    func test_when_render_then_numbers_and_delete_button_are_shown() throws {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        XCTAssertTrue(keypad.waitForExistence(timeout: 2))

        for number in 0...9 {
            let button = keypad.buttons["keypad_\(number)"]
            XCTAssertTrue(button.exists)
            XCTAssertEqual(button.label, "\(number)")
        }
        let emptyButton = keypad.buttons["keypad_empty"]
        let deleteButton = keypad.buttons["keypad_delete"]
        XCTAssertTrue(emptyButton.exists)
        XCTAssertEqual(emptyButton.label, "")
        XCTAssertTrue(deleteButton.exists)
        XCTAssertEqual(deleteButton.label, "delete")
    }

    @MainActor
    func test_when_render_then_heading_and_description_are_shown() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.staticTexts["방 코드"].waitForExistence(timeout: 2),
        )
        XCTAssertTrue(
            app.staticTexts["두 기기에 같은 코드를 입력하세요"].waitForExistence(timeout: 2),
        )
    }

    @MainActor
    func test_when_render_then_call_button_is_disabled() {
        let app = XCUIApplication()
        app.launch()

        let callButton = app.buttons["call_button"]
        XCTAssertTrue(
            callButton.waitForExistence(timeout: 2),
        )
        XCTAssertFalse(callButton.isEnabled)
        XCTAssertEqual(callButton.label, "통화 시작")
    }

    @MainActor
    func test_when_tap_4_digits_then_call_button_is_enabled() {
        let cases = [
            ["1", "2", "3", "4"],
            ["5", "6", "7", "8"],
            ["9", "0", "3", "4"],
        ]
        for tc in cases {
            let app = XCUIApplication()
            app.launch()

            let callButton = app.buttons["call_button"]
            let keypad = app.otherElements["numbers_keypad"]
            keypad.buttons["keypad_\(tc[0])"].tap()
            XCTAssertFalse(callButton.isEnabled)
            keypad.buttons["keypad_\(tc[1])"].tap()
            XCTAssertFalse(callButton.isEnabled)
            keypad.buttons["keypad_\(tc[2])"].tap()
            XCTAssertFalse(callButton.isEnabled)
            keypad.buttons["keypad_\(tc[3])"].tap()

            XCTAssertTrue(callButton.isEnabled)
        }
    }

    @MainActor
    func test_when_tap_4_digits_then_tapped_digits_are_shown_in_input_fields() {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()

        let expected = ["1", "2", "3", "4"]
        for index in 0..<4 {
            let field = app.staticTexts["room_code_digit_\(index)"]

            XCTAssertTrue(field.exists)
            XCTAssertEqual(field.label, "\(expected[index])")
        }
    }

    @MainActor
    func test_when_tap_more_than_4_digits_then_only_4_digits_are_shown() {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        keypad.buttons["keypad_5"].tap()

        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        XCTAssertTrue(app.staticTexts["3"].exists)
        XCTAssertTrue(app.staticTexts["4"].exists)
        XCTAssertFalse(app.staticTexts["5"].exists)
    }

    @MainActor
    func test_when_tap_more_than_4_digits_then_call_button_is_enabled() {
        let cases = [
            ["1", "2", "3", "4", "5"],
            ["5", "6", "7", "8", "9"],
            ["9", "0", "1", "3", "4"],
        ]
        for tc in cases {
            let app = XCUIApplication()
            app.launch()

            let keypad = app.otherElements["numbers_keypad"]
            keypad.buttons["keypad_\(tc[0])"].tap()
            keypad.buttons["keypad_\(tc[1])"].tap()
            keypad.buttons["keypad_\(tc[2])"].tap()
            keypad.buttons["keypad_\(tc[3])"].tap()
            keypad.buttons["keypad_\(tc[4])"].tap()

            XCTAssertTrue(app.buttons["call_button"].isEnabled)
        }
    }

    @MainActor
    func test_when_tap_delete_button_then_last_digit_is_removed() {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        keypad.buttons["keypad_delete"].tap()

        XCTAssertFalse(app.buttons["call_button"].isEnabled)
        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        XCTAssertTrue(app.staticTexts["3"].exists)
        XCTAssertFalse(app.staticTexts["4"].exists)
    }

    @MainActor
    func
        test_given_5_digits_are_tapped_when_tap_delete_button_then_last_digit_is_removed()
    {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        keypad.buttons["keypad_5"].tap()
        keypad.buttons["keypad_delete"].tap()

        XCTAssertFalse(app.buttons["call_button"].isEnabled)
        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        XCTAssertTrue(app.staticTexts["3"].exists)
        XCTAssertFalse(app.staticTexts["4"].exists)
        XCTAssertFalse(app.staticTexts["5"].exists)
    }

    @MainActor
    func
        test_when_tap_delete_button_more_than_entered_digits_then_all_digits_are_removed()
    {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_delete"].tap()
        keypad.buttons["keypad_delete"].tap()
        keypad.buttons["keypad_delete"].tap()

        XCTAssertFalse(app.buttons["call_button"].isEnabled)
        XCTAssertFalse(app.staticTexts["1"].exists)
        XCTAssertFalse(app.staticTexts["2"].exists)
    }
}
