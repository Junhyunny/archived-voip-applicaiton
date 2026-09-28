//
//  WebRTCClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

import WebRTC

nonisolated protocol WebRTCClient {
    var events: AsyncStream<WebRTCEvent> { get }

    func createOffer() async throws -> String
    func setRemoteOffer(_ sdp: String) async throws
    func createAnswer() async throws -> String
    func setRemoteAnswer(_ sdp: String) async throws
    func addCandidate(_ candidate: IceCandidatePayload) async
}

let DEFAULT_FACTORY: RTCPeerConnectionFactory = {
    RTCInitializeSSL()
    return RTCPeerConnectionFactory()
}()

actor RemoteCandidateBuffer {
    private var hasRemoteDescription = false
    private var pending: [RTCIceCandidate] = []

    func markRemoteSetAndDrain() -> [RTCIceCandidate] {
        hasRemoteDescription = true
        defer {
            pending.removeAll()
        }
        return pending
    }

    func accept(candidate: RTCIceCandidate) -> Bool {
        if !hasRemoteDescription {
            pending.append(candidate)
            return false
        }
        return true
    }
}

class WebRTCClientImpl: NSObject, WebRTCClient {
    private let peerConnection: RTCPeerConnection
    private let factory: RTCPeerConnectionFactory
    private let buffer: RemoteCandidateBuffer

    let events: AsyncStream<WebRTCEvent>
    let continuation: AsyncStream<WebRTCEvent>.Continuation

    private static func rtcConfiguration() -> RTCConfiguration {
        let configuration = RTCConfiguration()
        configuration.iceServers = [
            RTCIceServer(
                urlStrings: [
                    "stun:stun.l.google.com:19302"
                ]
            )
        ]
        configuration.sdpSemantics = .unifiedPlan
        configuration.continualGatheringPolicy = .gatherContinually
        return configuration
    }

    private static func rtcConstraints() -> RTCMediaConstraints {
        return RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
    }

    init(factory: RTCPeerConnectionFactory = DEFAULT_FACTORY) {
        self.factory = factory
        var continuation: AsyncStream<WebRTCEvent>.Continuation!
        self.events = AsyncStream { continuatinStream in
            continuation = continuatinStream
        }
        self.continuation = continuation
        self.buffer = RemoteCandidateBuffer()

        guard
            let peerConnection = factory.peerConnection(
                with: Self.rtcConfiguration(),
                constraints: Self.rtcConstraints(),
                delegate: nil
            )
        else {
            fatalError("failed to create RTCPeerConnection")
        }
        self.peerConnection = peerConnection

        super.init()
        self.peerConnection.delegate = self
        self.addLocalAudioTrack()
    }

    private func addLocalAudioTrack() {
        let audioTrack = self.factory.audioTrack(withTrackId: "audio0")
        peerConnection.add(audioTrack, streamIds: ["stream0"])
    }

    private var constraints: RTCMediaConstraints {
        RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
    }

    private func drainBufferedCandidates() async {
        for candidate in await buffer.markRemoteSetAndDrain() {
            do {
                try await peerConnection.add(candidate)
            } catch {
                print("failed to add ice candidate", error)
            }
        }
    }

    func createOffer() async throws -> String {
        let offer = try await peerConnection.offer(for: constraints)
        try await peerConnection.setLocalDescription(offer)
        return offer.sdp
    }

    func setRemoteOffer(_ sdp: String) async throws {
        try await peerConnection.setRemoteDescription(
            RTCSessionDescription(type: .offer, sdp: sdp)
        )
        await drainBufferedCandidates()
    }

    func createAnswer() async throws -> String {
        let answer = try await peerConnection.answer(for: constraints)
        try await peerConnection.setLocalDescription(answer)
        return answer.sdp
    }

    func setRemoteAnswer(_ sdp: String) async throws {
        try await peerConnection.setRemoteDescription(
            RTCSessionDescription(type: .answer, sdp: sdp)
        )
        await drainBufferedCandidates()
    }

    func addCandidate(_ candidate: IceCandidatePayload) async {
        let iceCandidate = RTCIceCandidate(
            sdp: candidate.candidate,
            sdpMLineIndex: candidate.sdpMLineIndex,
            sdpMid: candidate.sdpMid
        )
        guard await buffer.accept(candidate: iceCandidate) else { return }
        do {
            try await peerConnection.add(iceCandidate)
        } catch {
            print("failed to add ice candidate", error)
        }
    }
}
