//
//  SignalingClientTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import FlyingFox
import Testing
import XCTest

@testable import voip_ios

@MainActor
struct SignalingClientTests {

    @Test
    func when_connect_then_web_socket_client_connection_is_fulfilled()
        async throws
    {
        let mockStore = MockMessageStore()
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                MockWSMessageHandler(store: mockStore),
            ),
        ) { port in
            let sut = SignalingClient(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )

            try await sut.connect()

            #expect(sut.callingStatus == .idle)
        }
    }

    @Test
    func
        given_web_socket_is_connected_when_joining_then_server_receive_join_request()
        async throws
    {
        let mockStore = MockMessageStore()
        await mockStore.setResponse(
            WSMessage.text(
                """
                {
                    "type": "joined"
                }
                """
            )
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                MockWSMessageHandler(store: mockStore),
            ),
        ) { port in
            let sut = SignalingClient(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            try await sut.connect()

            try await sut.join(roomCode: "1234")

            try await waitUntil(timeout: Duration.seconds(5)) {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let map = parsedMessages[0]
            #expect(map.count == 2)
            #expect(map["roomCode"] as? String == "1234")
            #expect(map["type"] as? String == "join")
            try await waitUntil(timeout: Duration.seconds(5)) {
                sut.callingStatus == .joined
            }
        }
    }

    @Test
    func
        given_try_join_when_receive_join_failed_then_server_receive_join_request()
        async throws
    {
        let mockStore = MockMessageStore()
        await mockStore.setResponse(
            WSMessage.text(
                """
                {
                    "type": "join_failed"
                }
                """
            )
        )
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                MockWSMessageHandler(store: mockStore),
            ),
        ) { port in
            let sut = SignalingClient(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            try await sut.connect()

            try await sut.join(roomCode: "1234")

            try await waitUntil(timeout: Duration.seconds(5)) {
                sut.callingStatus == .join_failed
            }
        }
    }
}
