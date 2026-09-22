//
//  MockWSMessageHandler.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import FlyingFox
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

    init(store: MockMessageStore) {
        self.store = store
    }

    func makeMessages(
        for client: AsyncStream<WSMessage>
    ) async throws -> AsyncStream<WSMessage> {
        return AsyncStream { continuation in
            Task {
                for await message in client {
                    if case .text(let text) = message {
                        await store.append(text)
                    }
                    let stub = await store.response

                    continuation.yield(stub)
                }
                continuation.finish()
            }
        }
    }
}

func withMockServer(
    store: MockMessageStore,
    route: (HTTPRoute, WSMessageHandler),
    _ body: (_ port: UInt16) async throws -> Void
) async throws {
    let port = UInt16.random(in: 10_000...60_000)
    let server = HTTPServer(port: port)
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
