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
    func when_connect_then_connect_signaling_event_yield()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()

            try await sut.connect()

            let event = await iterator.next()
            #expect(event == .connected)
        }
    }

    @Test
    func
        given_join_is_possible_when_join_then_server_receive_join_request()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            try await sut.connect()

            try await sut.join(roomCode: "1234")

            try await waitFor(timeout: Duration.seconds(5)) {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let map = parsedMessages[0]
            #expect(map.count == 2)
            #expect(map["type"] as? String == "join")
            let payload = map["payload"] as? [String: Any?]
            #expect(payload?["roomCode"] as? String == "1234")
        }
    }

    @Test
    func
        given_join_is_possible_when_join_then_joined_signaling_event_yield()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.join(roomCode: "1234")

            let event = await iterator.next()
            #expect(event == .joined)
        }
    }

    @Test
    func
        given_join_is_impossible_when_join_then_join_failed_signaling_event_yield()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.join(roomCode: "1234")

            let event = await iterator.next()
            #expect(event == .joinFailed)
        }
    }
    
    @Test
    func
        given_peer_joined_when_join_then_peer_joined_signaling_event_yield()
        async throws
    {
        let mockStore = MockMessageStore()
        await mockStore.setResponse(
            WSMessage.text(
                """
                {
                    "type": "peer_joined"
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.join(roomCode: "1234")

            let event = await iterator.next()
            #expect(event == .peerJoined)
        }
    }
}
