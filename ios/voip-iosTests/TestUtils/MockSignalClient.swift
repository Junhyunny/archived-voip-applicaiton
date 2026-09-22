//
//  MockSignalingClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

@testable import voip_ios

enum MockSingalError: Error {
    case sample
}

class MockSignalClient: SignalClient {
    private(set) var connect_called_times: Int = 0
    private(set) var join_called_times: Int = 0
    private(set) var join_roomCode: String?
    var connect_error: MockSingalError?
    var join_error: MockSingalError?

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
        connect_called_times += 1
        if let error = connect_error {
            throw error
        }
    }

    func join(roomCode: String) async throws {
        join_called_times += 1
        join_roomCode = roomCode
        if let error = join_error {
            throw error
        }
    }
}
