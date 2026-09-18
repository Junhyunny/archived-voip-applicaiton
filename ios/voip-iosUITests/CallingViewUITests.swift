//
//  CallingViewUITests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import XCTest

final class CallingViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func navigateToCallingView(timeLimit: Int = 60) {
        app = XCUIApplication()
        app.launchEnvironment["CALL_TIME_LIMIT_SECONDS"] = String(timeLimit)
        app.launch()
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

    @MainActor
    func test_when_render_then_see_connecting_information() {
        navigateToCallingView()

        XCTAssertTrue(app.staticTexts["연결 중"].exists)
        XCTAssertTrue(app.staticTexts["1234"].exists)
        XCTAssertTrue(app.staticTexts["상대방을 기다리고 있어요"].exists)
        XCTAssertTrue(
            app.staticTexts
                .matching(NSPredicate(format: "label CONTAINS %@", "초 후 자동 종료"))
                .firstMatch
                .exists
        )
        XCTAssertTrue(
            app.staticTexts["같은 코드 1234 를 다른 기기에서 입력하면 바로 통화가 시작됩니다"].exists
        )
    }

    @MainActor
    func test_when_tap_cancel_button_then_navigate_enter_room_view() {
        navigateToCallingView()
        app.buttons["cancel_button"].tap()

        let enterRoomView = app.otherElements["enter_room_view"]
        let callingView = app.otherElements["calling_view"]
        XCTAssertTrue(enterRoomView.waitForExistence(timeout: 2))
        XCTAssertFalse(callingView.exists)
    }

    @MainActor
    func
        test_given_2s_are_left_when_2s_are_passed_then_navigate_enter_room_view()
    {
        navigateToCallingView(timeLimit: 2)

        let enterRoomView = app.otherElements["enter_room_view"]
        let callingView = app.otherElements["calling_view"]
        XCTAssertTrue(enterRoomView.waitForExistence(timeout: 3))
        XCTAssertFalse(callingView.exists)
    }
}
