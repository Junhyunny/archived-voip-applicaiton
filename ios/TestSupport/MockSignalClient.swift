//
//  MockSignalClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

@testable import voip_ios

enum MockSignalError: Error {
    case sample
}

class MockSignalClient: SignalClient {
    private(set) var connectCalledTimes: Int = 0
    private(set) var joinCalledTimes: Int = 0
    private(set) var joinRoomCode: String?
    var connectError: MockSignalError?
    var joinError: MockSignalError?

    let events: AsyncStream<voip_ios.SignalEvent>
    private(set) var continuation: AsyncStream<SignalEvent>.Continuation

    init() {
        var continuation: AsyncStream<SignalEvent>.Continuation!
        self.events = AsyncStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    func connect() async throws {
        connectCalledTimes += 1
        if let error = connectError {
            throw error
        }
    }

    func join(roomCode: String) async throws {
        joinCalledTimes += 1
        joinRoomCode = roomCode
        if let error = joinError {
            throw error
        }
    }
}
