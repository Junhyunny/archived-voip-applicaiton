//
//  ContentViewUITests.swift
//  voip-ios
//
//  Created by 강준현 on 9/17/26.
//

import XCTest

final class ContentViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_when_tap_start_call_button_then_move_to_calling_page() {
        let app = XCUIApplication()
        app.launch()

        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        app.buttons["call_button"].tap()

        let callingPage = app.otherElements["calling_view"]
        let enterRoomPage = app.otherElements["enter_room_view"]
        XCTAssertTrue(callingPage.waitForExistence(timeout: 2))
        XCTAssertFalse(enterRoomPage.exists)
    }
}
