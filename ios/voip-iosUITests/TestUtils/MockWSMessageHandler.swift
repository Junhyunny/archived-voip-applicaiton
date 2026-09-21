//
//  MockWSMessageHandler.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import FlyingFox

actor MockMessageStore {
    private(set) var messages: [String] = []

    func append(_ message: String) {
        messages.append(message)
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
                    continuation.yield(message)
                }
                continuation.finish()
            }
        }
    }
}
