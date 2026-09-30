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

@Suite(.timeLimit(.minutes(1)))
@MainActor
struct SignalClientTests {

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

            try await waitFor {
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

    @Test func `when send offer then server receives offer request`()
        async throws
    {
        let mockStore = MockMessageStore()
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                MockWSMessageHandler(store: mockStore),
            )
        ) { port in
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.send(offer: "session description payload")

            try await waitFor {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            let map = parsedMessages[0]
            #expect(map["type"] as? String == "offer")
            let payload = map["payload"] as? [String: Any?]
            #expect(payload?["sdp"] as? String == "session description payload")
        }
    }

    @Test func `when receive offer message then yield offer event`()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler,
            )
        ) { port in
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            mockHandler.push(
                WSMessage.text(
                    """
                    {
                        "type": "offer",
                        "payload": {
                            "sdp": "session description payload"
                        }
                    }
                    """
                )
            )

            let event: SignalEvent = await iterator.next()!
            #expect(event == .offer("session description payload"))
        }
    }

    @Test func `when send answer then server receives answer request`()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.send(answer: "session description payload")

            try await waitFor {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            #expect(parsedMessages.count == 1)

            let map = parsedMessages[0]
            #expect(map["type"] as? String == "answer")
            let payload = map["payload"] as? [String: Any?]
            #expect(payload?["sdp"] as? String == "session description payload")

        }
    }

    @Test func `when receive answer message then yield answer event`()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler,
            )
        ) { port in
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            mockHandler.push(
                WSMessage.text(
                    """
                    {
                        "type": "answer",
                        "payload": {
                            "sdp": "session description payload"
                        }
                    }
                    """
                )
            )

            let event: SignalEvent = await iterator.next()!
            #expect(event == .answer("session description payload"))
        }
    }

    @Test func `when receive peerLeft message then yield peerLeft event`()
        async throws
    {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler,
            )
        ) { port in
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            mockHandler.push(
                WSMessage.text(
                    """
                    {
                        "type": "peer_left"
                    }
                    """
                )
            )

            let event: SignalEvent = await iterator.next()!
            #expect(event == .peerLeft)
        }
    }

    @Test func `when send ice candidate then server receives offer request`()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            try await sut.send(
                candidate: IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0,
                )
            )

            try await waitFor {
                await mockStore.messages.count == 1
            }
            let parsedMessages = try parseMessage(
                messages: await mockStore.messages
            )
            #expect(parsedMessages.count == 1)

            let map = parsedMessages[0]
            #expect(map["type"] as? String == "ice_candidate")
            let payload = map["payload"] as? [String: Any?]
            #expect(payload?["candidate"] as? String == "candidate")
            #expect(payload?["sdpMid"] as? String == "sdpMid")
            #expect(payload?["sdpMLineIndex"] as? Int == 0)
        }
    }

    @Test
    func `when receive iceCandidate message then yeild iceCandidate event`()
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            var iterator = sut.events.makeAsyncIterator()
            try await sut.connect()
            _ = await iterator.next()

            mockHandler.push(
                WSMessage.text(
                    """
                    {
                        "type": "ice_candidate",
                        "payload": {
                            "candidate": "candidate",
                            "sdpMid": "sdpMid",
                            "sdpMLineIndex": 0
                        }
                    }
                    """
                )
            )

            let event: SignalEvent = await iterator.next()!
            #expect(
                event
                    == .iceCandidate(
                        IceCandidatePayload(
                            candidate: "candidate",
                            sdpMid: "sdpMid",
                            sdpMLineIndex: 0
                        )
                    )
            )
        }
    }

    @Test func `when send after close then throws taskNotCreated`() async throws
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
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            try await sut.connect()

            sut.close()

            await #expect(throws: SignalError.taskNotCreated) {
                try await sut.join(roomCode: "1234")
            }
            await #expect(throws: SignalError.taskNotCreated) {
                try await sut.send(offer: "v=0")
            }
        }
    }

    @Test func `when leave then send leave message`() async throws {
        let mockStore = MockMessageStore()
        let mockHandler = MockWSMessageHandler(store: mockStore)
        try await withMockServer(
            store: mockStore,
            route: (
                "GET /signaling",
                mockHandler
            )
        ) { port in
            let sut = SignalClientImpl(
                url: URL(string: "ws://localhost:\(port)/signaling")!
            )
            try await sut.connect()

            try await sut.leave()

            try await waitFor {
                await mockStore.messages.count >= 1
            }
            #expect(await mockStore.messages.count == 1)
            let parsedMessage = try parseMessage(
                messages: await mockStore.messages
            )
            let message = parsedMessage.first!
            #expect(message["type"] as? String == "leave")
        }
    }
}
