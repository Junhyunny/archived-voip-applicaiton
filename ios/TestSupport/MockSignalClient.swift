//
//  MockSignalClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

@testable import voip_ios

class MockSignalClient: SignalClient {
    let events: AsyncStream<voip_ios.SignalEvent>
    private(set) var continuation: AsyncStream<SignalEvent>.Continuation

    init() {
        var continuation: AsyncStream<SignalEvent>.Continuation!
        self.events = AsyncStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    private(set) var connectCalledTimes: Int = 0
    var connectError: MockError?

    func connect() async throws {
        connectCalledTimes += 1
        if let error = connectError {
            throw error
        }
    }

    private(set) var closeCalledTimes: Int = 0

    func close() {
        closeCalledTimes += 1
    }

    private(set) var joinCalledTimes: Int = 0
    private(set) var joinRoomCode: String?
    var joinError: MockError?

    func join(roomCode: String) async throws {
        joinCalledTimes += 1
        joinRoomCode = roomCode
        if let error = joinError {
            throw error
        }
    }

    private(set) var sendOfferCallTimes: Int = 0
    private(set) var sendOfferSdp: String?
    var sendOfferError: MockError?

    func send(offer: String) async throws {
        sendOfferCallTimes += 1
        sendOfferSdp = offer
        if let error = sendOfferError {
            throw error
        }
    }

    private(set) var sendAnswerCallTimes: Int = 0
    private(set) var sendAnswerSdp: String?
    var sendAnswerError: MockError?

    func send(answer: String) async throws {
        sendAnswerCallTimes += 1
        sendAnswerSdp = answer
        if let error = sendAnswerError {
            throw error
        }
    }

    private(set) var sendCandidateCallTimes: Int = 0
    private(set) var sendCandidateCnadidate: IceCandidatePayload?
    var sendCandidateError: MockError?

    func send(candidate: IceCandidatePayload) async throws {
        sendCandidateCallTimes += 1
        sendCandidateCnadidate = candidate
        if let error = sendCandidateError {
            throw error
        }
    }

    private(set) var leaveCallTimes: Int = 0

    func leave() async throws {
        leaveCallTimes += 1
    }
}
