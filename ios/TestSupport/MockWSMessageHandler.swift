//
//  MockWSMessageHandler.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import FlyingFox
import FlyingSocks
import Foundation

actor MockMessageStore {
    private(set) var messages: [String] = []
    private(set) var response: WSMessage = WSMessage.text("{}")

    func append(_ message: String) {
        messages.append(message)
    }

    func setResponse(_ response: WSMessage) {
        self.response = response
    }

}

final class MockWSMessageHandler: WSMessageHandler {

    let store: MockMessageStore
    let asyncSrteam: AsyncStream<WSMessage>
    let continuation: AsyncStream<WSMessage>.Continuation

    init(store: MockMessageStore) {
        self.store = store
        var continuation: AsyncStream<WSMessage>.Continuation!
        asyncSrteam = AsyncStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    func push(_ message: WSMessage) {
        self.continuation.yield(message)
    }

    func makeMessages(
        for client: AsyncStream<WSMessage>
    ) async throws -> AsyncStream<WSMessage> {
        Task { [store, continuation] in
            for await message in client {
                if case .text(let text) = message {
                    await store.append(text)
                }
                let stub = await store.response
                continuation.yield(stub)
            }
            continuation.finish()
        }
        return asyncSrteam
    }
}

func withMockServer(
    store: MockMessageStore,
    route: (HTTPRoute, WSMessageHandler),
    _ body: (_ port: UInt16) async throws -> Void
) async throws {
    let server = HTTPServer(port: 0)
    await server.appendRoute(
        route.0,
        to: .webSocket(route.1)
    )
    defer {
        await server.stop()
    }
    Task {
        do {
            try await server.run()
        } catch {
            print("server error:", error)
        }
    }
    try await server.waitUntilListening()
    guard let address = await server.listeningAddress else {
        throw MockServerError.notFoundAddress
    }
    var port: UInt16 = 0
    switch address {
    case .ip4(_, let portNumber):
        port = portNumber
    case .ip6(_, let portNumber):
        port = portNumber
    case .unix:
        throw MockServerError.notFoundPort
    }
    try await body(port)
}

func parseMessage(messages: [String]) throws -> [[String: Any?]] {
    var result = [[String: Any?]]()
    for message in messages {
        let data = Data(message.utf8)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let map = json as? [String: Any] else {
            continue
        }
        result.append(map)
    }
    return result
}

enum MockServerError: Error {
    case notFoundAddress
    case notFoundPort
}
