//
//  CallingViewUITests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import FlyingFox
import XCTest

final class CallingViewUITests: XCTestCase {
    private var app: XCUIApplication!

    var mockMessageStore: MockMessageStore!
    var mockServer: HTTPServer!
    override func setUp() async throws {
        continueAfterFailure = false
        mockMessageStore = MockMessageStore()
        mockServer = await setupWebSocket(
            routes: [
                (
                    "GET /signaling",
                    MockWSMessageHandler(store: mockMessageStore)
                )
            ]
        )
    }

    override func tearDown() async throws {
        await mockServer.stop(timeout: 2)
    }

    private func setupWebSocket(routes: [(HTTPRoute, WSMessageHandler)]) async
        -> HTTPServer
    {
        let server = HTTPServer(port: 8080)
        for route in routes {
            await server.appendRoute(
                route.0,
                to: .webSocket(route.1)
            )
        }
        _ = Task {
            do {
                try await server.run()
            } catch {
                print("server error:", error)
            }
        }
        try? await server.waitUntilListening()
        return server
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
        XCTAssertTrue(enterRoomView.waitForExistence(timeout: 5))
        XCTAssertFalse(callingView.exists)
    }

    @MainActor
    func test_when_render_then_send_join_request_to_signaling_sever()
        async throws
    {
        navigateToCallingView()

        try await waitFor(timeout: .seconds(5)) {
            await self.mockMessageStore.messages.count == 1
        }
        let messages = await mockMessageStore.messages
        XCTAssertEqual(messages.count, 1)

        let data = Data(messages[0].utf8)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let map = json as? [String: Any] else {
            XCTFail("Expected JSON object")
            return
        }
        XCTAssertEqual(map.count, 2)
        XCTAssertEqual(map["type"] as? String, "join")
        let payload: [String: Any?]? = map["payload"] as? [String: Any?]
        XCTAssertEqual(payload?["roomCode"] as? String, "1234")
    }
}
