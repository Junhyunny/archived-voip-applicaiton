//
//  EnterRoomViewUITests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import XCTest

final class CallingViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        navigateToCallingView()
    }

    private func navigateToCallingView() {
        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        app.buttons["call_button"].tap()
        XCTAssertTrue(
            app.otherElements["calling_view"]
                .waitForExistence(timeout: 2)
        )
    }
    
    func test_when_render_todo() {
        // TODO
    }
}
