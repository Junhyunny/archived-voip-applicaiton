//
//  MockWebRTCClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/29/26.
//

@testable import voip_ios

class MockWebRTCClient: WebRTCClient {
    let events: AsyncStream<WebRTCEvent>
    var continuation: AsyncStream<WebRTCEvent>.Continuation

    init() {
        var continuation: AsyncStream<WebRTCEvent>.Continuation!
        self.events = AsyncStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    private(set) var createOfferCallTimes: Int = 0
    var createOfferReturn: String?
    var createOfferError: MockError?

    func createOffer() async throws -> String {
        createOfferCallTimes += 1
        if let error = createOfferError {
            throw error
        }
        return createOfferReturn ?? ""
    }

    private(set) var acceptOfferCalled: Int = 0
    private(set) var acceptOfferSdp: String?
    var acceptOfferReturn: String?
    var acceptOfferError: MockError?

    func acceptOffer(_ sdp: String) async throws -> String {
        acceptOfferCalled += 1
        acceptOfferSdp = sdp
        if let error = acceptOfferError {
            throw error
        }
        return acceptOfferReturn ?? ""
    }

    private(set) var setRemoteAnswerCalled: Int = 0
    private(set) var setRemoteAnswerSdp: String?
    var setRemoteAnswerError: MockError?

    func setRemoteAnswer(_ sdp: String) async throws {
        setRemoteAnswerCalled += 1
        setRemoteAnswerSdp = sdp
        if let error = setRemoteAnswerError {
            throw error
        }
    }

    private(set) var addCandidateCalled: Int = 0
    private(set) var addCandidateCandidates: [IceCandidatePayload] = []
    var addCandidateError: MockError?

    func addCandidate(_ candidate: IceCandidatePayload) async throws {
        addCandidateCalled += 1
        addCandidateCandidates.append(candidate)
        if let error = addCandidateError {
            throw error
        }
    }

    private(set) var closeCalledTimes: Int = 0

    func close() {
        closeCalledTimes += 1
    }
}
