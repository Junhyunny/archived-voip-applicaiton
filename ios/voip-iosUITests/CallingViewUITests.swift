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

    override func setUp() async throws {
        continueAfterFailure = false
    }

    private func navigateToCallingView(
        timeLimit: Int = 60,
        port: UInt16 = 8080
    ) {
        app = XCUIApplication()
        app.launchEnvironment["CALL_TIME_LIMIT_SECONDS"] = String(timeLimit)
        app.launchEnvironment["SIGNALING_URL"] = String(
            "ws://localhost:\(port)/signaling"
        )
        app.launch()
        let keypad = app.otherElements["numbers_keypad"]
        keypad.buttons["keypad_1"].tap()
        keypad.buttons["keypad_2"].tap()
        keypad.buttons["keypad_3"].tap()
        keypad.buttons["keypad_4"].tap()
        app.buttons["call_button"].tap()
    }

    @MainActor
    func test_when_render_then_connecting_information_is_shown() async throws {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)

            XCTAssertTrue(
                app.otherElements["calling_view"]
                    .waitForExistence(timeout: 2)
            )
            XCTAssertTrue(app.staticTexts["연결 중"].exists)
            XCTAssertTrue(app.staticTexts["1234"].exists)
            XCTAssertTrue(app.staticTexts["상대방을 기다리고 있어요"].exists)
            XCTAssertEqual(
                app.images["checkbox_join_signaling"].value
                    as? String,
                "unchecked"
            )
            XCTAssertTrue(app.staticTexts["시그널링 서버 연결"].exists)
            XCTAssertEqual(
                app.images["checkbox_peer_joined"].value as? String,
                "unchecked"
            )
            XCTAssertTrue(app.staticTexts["상대방 입장"].exists)
            XCTAssertTrue(
                app.staticTexts
                    .matching(
                        NSPredicate(format: "label CONTAINS %@", "초 후 자동 종료")
                    )
                    .firstMatch
                    .exists
            )
            XCTAssertTrue(
                app.staticTexts["같은 코드 1234 를 다른 기기에서 입력하면 바로 통화가 시작됩니다"].exists
            )
            XCTAssertTrue(app.buttons["취소"].exists)
        }
    }

    @MainActor
    func test_when_tap_cancel_button_then_enter_room_view_is_shown()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)
            XCTAssertTrue(
                app.otherElements["calling_view"]
                    .waitForExistence(timeout: 2)
            )
            await mockStore.clearMessages()

            app.buttons["cancel_button"].tap()

            try await waitFor {
                return await mockStore.messages.count >= 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessages.last!
            XCTAssertEqual(message.count, 2)
            XCTAssertEqual(message["type"] as? String, "leave")

            let enterRoomView = app.otherElements["enter_room_view"]
            let callingView = app.otherElements["calling_view"]
            XCTAssertTrue(enterRoomView.waitForExistence(timeout: 2))
            XCTAssertFalse(callingView.exists)
        }
    }

    @MainActor
    func
        test_given_2s_are_left_when_2s_are_passed_then_enter_room_view_is_shown()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(timeLimit: 2, port: port)
            XCTAssertTrue(
                app.otherElements["calling_view"]
                    .waitForExistence(timeout: 2)
            )

            try? await Task.sleep(for: .seconds(3))

            let enterRoomView = app.otherElements["enter_room_view"]
            XCTAssertTrue(enterRoomView.waitForExistence(timeout: 5))
            let callingView = app.otherElements["calling_view"]
            XCTAssertFalse(callingView.exists)
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessages.last!
            XCTAssertEqual(message.count, 2)
            XCTAssertEqual(message["type"] as? String, "leave")
        }
    }

    @MainActor
    func test_when_render_then_join_request_is_sent_to_signaling_server()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)

            try await waitFor {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessages.last!
            XCTAssertEqual(message.count, 2)
            XCTAssertEqual(message["type"] as? String, "join")
            let payload: [String: Any?]? = message["payload"] as? [String: Any?]
            XCTAssertEqual(payload?["roomCode"] as? String, "1234")
        }
    }

    @MainActor
    func test_when_peer_joined_then_info_text_is_changed() async throws {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)
            try await waitFor {
                await mockStore.messages.count == 1
            }

            mockHandler.push(
                WSMessage.text(
                    """
                    {
                        "type": "peer_joined"
                    }
                    """
                )
            )

            XCTAssertTrue(
                app.staticTexts["상대방이 입장했어요"].waitForExistence(timeout: 10)
            )
            XCTAssertTrue(app.staticTexts["음성을 연결하고 있어요"].exists)
            XCTAssertTrue(app.staticTexts["잠시 후 통화 화면으로 이동합니다"].exists)
            XCTAssertEqual(
                app.images["checkbox_join_signaling"].value
                    as? String,
                "checked"
            )
            XCTAssertTrue(app.staticTexts["시그널링 서버 연결"].exists)
            XCTAssertEqual(
                app.images["checkbox_peer_joined"].value as? String,
                "checked"
            )
            XCTAssertTrue(app.staticTexts["상대방 입장"].exists)
            XCTAssertTrue(
                app.staticTexts
                    .matching(
                        NSPredicate(format: "label CONTAINS %@", "초 후 자동 종료")
                    )
                    .firstMatch
                    .exists
            )
            XCTAssertFalse(app.staticTexts["상대방을 기다리고 있어요"].exists)
            XCTAssertFalse(
                app.staticTexts["같은 코드 1234 를 다른 기기에서 입력하면 바로 통화가 시작됩니다"].exists
            )
        }
    }

    @MainActor
    func test_when_webRTC_is_connected_then_info_text_is_changed()
        async throws
    {
        var c: AsyncStream<WSMessage>.Continuation!
        let stream = AsyncStream<WSMessage> { c = $0 }
        let continuation = c!
        let peer = FakeRemotePeer(send: { json in
            continuation.yield(.text(json))
        })
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(
            store: mockStore,
            outboundStream: stream,
            continuation: continuation,
            onClientMessage: { text in await peer.handle(text) }
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)

            XCTAssertTrue(
                app.staticTexts["연결됨 · P2P"].waitForExistence(
                    timeout: 10
                )
            )
            XCTAssertTrue(app.staticTexts["연결됨 · P2P"].exists)
            XCTAssertTrue(app.staticTexts["1234"].exists)
            XCTAssertTrue(app.staticTexts["방 코드 1234 로 통화 중"].exists)
            XCTAssertTrue(app.staticTexts["AI가 통화를 듣고 있어요"].exists)
            XCTAssertTrue(
                app.staticTexts["자막은 표시하지 않습니다. 통화가 끝나면 요약이 만들어집니다."].exists
            )
            XCTAssertTrue(app.buttons["통화 종료"].exists)
            XCTAssertTrue(app.buttons["leave_call"].exists)
            XCTAssertFalse(app.otherElements["connecting_view"].exists)
        }
    }

    @MainActor
    func
        test_given_peers_are_connected_when_tap_leave_button_then_calling_view_is_dismissed_and_leave_request_is_sent()
        async throws
    {
        var c: AsyncStream<WSMessage>.Continuation!
        let stream = AsyncStream<WSMessage> { c = $0 }
        let continuation = c!
        let peer = FakeRemotePeer(send: { json in
            continuation.yield(.text(json))
        })
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(
            store: mockStore,
            outboundStream: stream,
            continuation: continuation,
            onClientMessage: { text in await peer.handle(text) }
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)
            XCTAssertTrue(
                app.staticTexts["연결됨 · P2P"].waitForExistence(timeout: 10)
            )
            await mockStore.clearMessages()

            app.buttons["leave_call"].tap()

            try await waitFor {
                return await mockStore.messages.count >= 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessages.last!
            XCTAssertEqual(message.count, 2)
            XCTAssertEqual(message["type"] as? String, "leave")

            let enterRoomView = app.otherElements["enter_room_view"]
            let callingView = app.otherElements["calling_view"]
            XCTAssertTrue(enterRoomView.waitForExistence(timeout: 5))
            XCTAssertFalse(callingView.exists)
        }
    }

    @MainActor
    func
        test_when_peers_are_connected_then_timer_is_stopped_and_calling_view_is_kept()
        async throws
    {
        var c: AsyncStream<WSMessage>.Continuation!
        let stream = AsyncStream<WSMessage> { c = $0 }
        let continuation = c!
        let peer = FakeRemotePeer(send: { json in
            continuation.yield(.text(json))
        })
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(
            store: mockStore,
            outboundStream: stream,
            continuation: continuation,
            onClientMessage: { text in await peer.handle(text) }
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(timeLimit: 3, port: port)
            XCTAssertTrue(
                app.staticTexts["연결됨 · P2P"].waitForExistence(timeout: 10)
            )

            try? await Task.sleep(for: .seconds(5))

            let callingView = app.otherElements["calling_view"]
            let enterRoomView = app.otherElements["enter_room_view"]
            XCTAssertTrue(callingView.waitForExistence(timeout: 5))
            XCTAssertFalse(enterRoomView.exists)
        }
    }

    @MainActor
    func
        test_given_peers_are_connected_when_peerLeft_event_is_received_then_calling_view_is_dismissed_and_leave_request_is_sent()
        async throws
    {
        var c: AsyncStream<WSMessage>.Continuation!
        let stream = AsyncStream<WSMessage> { c = $0 }
        let continuation = c!
        let peer = FakeRemotePeer(send: { json in
            continuation.yield(.text(json))
        })
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(
            store: mockStore,
            outboundStream: stream,
            continuation: continuation,
            onClientMessage: { text in await peer.handle(text) }
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            navigateToCallingView(port: port)
            XCTAssertTrue(
                app.staticTexts["연결됨 · P2P"].waitForExistence(timeout: 10)
            )
            await mockStore.clearMessages()

            mockHandler.continuation.yield(
                WSMessage.text(
                    """
                    {
                        "type": "peer_left"
                    }
                    """
                )
            )

            try await waitFor {
                return await mockStore.messages.count >= 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessages.last!
            XCTAssertEqual(message.count, 2)
            XCTAssertEqual(message["type"] as? String, "leave")

            let enterRoomView = app.otherElements["enter_room_view"]
            let callingView = app.otherElements["calling_view"]
            XCTAssertTrue(enterRoomView.waitForExistence(timeout: 5))
            XCTAssertFalse(callingView.exists)
        }
    }
}
