//
//  WebRTCClientTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/28/26.
//

import Testing
import WebRTC

@testable import voip_ios

class MockRTCPeerConnectionFactory: RTCPeerConnectionFactory {
    var peerConnection_called_times: Int = 0
    var peerConnection_configuration: RTCConfiguration?
    var peerConnection_contstraints: RTCMediaConstraints?
    var peerConnection_delegate: RTCPeerConnectionDelegate?
    var createdConnection: RTCPeerConnection!

    override func peerConnection(
        with configuration: RTCConfiguration,
        constraints: RTCMediaConstraints,
        delegate: (any RTCPeerConnectionDelegate)?
    ) -> RTCPeerConnection? {
        peerConnection_called_times += 1
        peerConnection_configuration = configuration
        peerConnection_contstraints = constraints
        peerConnection_delegate = delegate
        createdConnection = super.peerConnection(
            with: configuration,
            constraints: constraints,
            delegate: delegate
        )
        return createdConnection
    }
}

@Suite(.timeLimit(.minutes(1)))
@MainActor
struct WebRTCClientTests {

    var mockConnectionFactory: MockRTCPeerConnectionFactory
    var sut: WebRTCClientImpl

    init() {
        mockConnectionFactory = MockRTCPeerConnectionFactory()
        sut = WebRTCClientImpl(factory: mockConnectionFactory)
    }

    @Test
    func
        `when init client then peerConnection is called proper configuration and media constraints`()
        async throws
    {
        #expect(mockConnectionFactory.peerConnection_called_times == 1)
        let configuration = mockConnectionFactory
            .peerConnection_configuration
        #expect(configuration?.iceServers.count == 1)
        #expect(
            configuration?.iceServers[0].urlStrings == [
                "stun:stun.l.google.com:19302"
            ]
        )
        #expect(configuration?.sdpSemantics == .unifiedPlan)
        #expect(configuration?.continualGatheringPolicy == .gatherContinually)

        let mediaConstraints = mockConnectionFactory
            .peerConnection_contstraints
        #expect(mediaConstraints != nil)

        let delegate = mockConnectionFactory.peerConnection_delegate
        #expect(delegate == nil)

        let pc = try #require(mockConnectionFactory.createdConnection)
        #expect(pc.signalingState == .stable)
    }

    @Test func `when init client then peerConnection has self as a delegate`()
        async throws
    {
        let pc = mockConnectionFactory.createdConnection

        #expect(pc?.delegate === sut)
    }

    @Test func `when init client then add audio track to peerConnection`()
        async throws
    {
        let pc = try #require(mockConnectionFactory.createdConnection)

        let senders = pc.senders
        #expect(senders.count == 1)
        let sender = try #require(pc.senders.first)
        #expect(sender.track?.kind == "audio")
        #expect(sender.track?.trackId == "audio0")
        #expect(sender.streamIds == ["stream0"])
        #expect(sender.track?.isEnabled == true)
    }

    @Test
    func
        `when create offer then set local description and return sdp information`()
        async throws
    {
        let pc = try #require(mockConnectionFactory.createdConnection)

        #expect(pc.localDescription == nil)

        let offerSdp = try await sut.createOffer()

        #expect(offerSdp.contains("m=audio"))
        #expect(offerSdp.contains("a=sendrecv"))
        #expect(offerSdp.contains("a=mid:0"))
        #expect(offerSdp.contains("a=group:BUNDLE 0"))
        #expect(pc.localDescription != nil)
        #expect(pc.localDescription?.sdp != nil)
        #expect(pc.localDescription?.type == .offer)
        #expect(pc.signalingState == .haveLocalOffer)
    }

    @Test func `when create offer then collect ice candidates`() async throws {
        let pc = try #require(mockConnectionFactory.createdConnection)
        #expect(pc.iceGatheringState == .new)

        _ = try await sut.createOffer()

        for await case .iceCandidate in sut.events {
            #expect(pc.iceGatheringState != .new)
            return
        }
        Issue.record("cannot found ice candidates")
    }

    @Test
    func
        `when set remote then remote description is changed in peer connection`()
        async throws
    {
        let otherClient = WebRTCClientImpl()
        let otherClientOfferSdp = try await otherClient.createOffer()
        let pc = try #require(mockConnectionFactory.createdConnection)

        #expect(pc.remoteDescription == nil)

        try await sut.setRemoteOffer(otherClientOfferSdp)

        #expect(pc.remoteDescription != nil)
        #expect(pc.remoteDescription?.sdp == otherClientOfferSdp)
        #expect(pc.remoteDescription?.type == .offer)
        #expect(pc.signalingState == .haveRemoteOffer)
    }

    @Test
    func
        `given set remote by using other client offer when create answer then set local description and return sdp information`()
        async throws
    {
        let otherClient = WebRTCClientImpl()
        let otherClientOfferSdp = try await otherClient.createOffer()
        try await sut.setRemoteOffer(otherClientOfferSdp)
        let pc = try #require(mockConnectionFactory.createdConnection)

        #expect(pc.localDescription == nil)

        let answer = try await sut.createAnswer()

        #expect(answer.contains("m=audio"))
        #expect(answer.contains("a=sendrecv"))
        #expect(answer.contains("a=mid:0"))
        #expect(answer.contains("a=group:BUNDLE 0"))
        #expect(pc.localDescription != nil)
        #expect(pc.localDescription?.sdp != nil)
        #expect(pc.localDescription?.type == .answer)
        #expect(pc.signalingState == .stable)
    }

    @Test
    func
        `given set remote by using other client offer when create answer then collect ice candidates`()
        async throws
    {
        let pc = try #require(mockConnectionFactory.createdConnection)
        let otherClient = WebRTCClientImpl()
        let otherClientOfferSdp = try await otherClient.createOffer()
        try await sut.setRemoteOffer(otherClientOfferSdp)
        #expect(pc.iceGatheringState == .new)

        _ = try await sut.createAnswer()

        for await case .iceCandidate in sut.events {
            #expect(pc.iceGatheringState != .new)
            return
        }
        Issue.record("cannot found ice candidates")
    }

    @Test
    func
        `given other client answer comes when set remote then remote description is changed in peer connection`()
        async throws
    {
        let myOffer = try await sut.createOffer()
        let otherClient = WebRTCClientImpl()
        try await otherClient.setRemoteOffer(myOffer)
        let otherClientAnswerSdp = try await otherClient.createAnswer()
        let pc = try #require(mockConnectionFactory.createdConnection)

        #expect(pc.remoteDescription == nil)

        try await sut.setRemoteAnswer(otherClientAnswerSdp)

        #expect(pc.remoteDescription != nil)
        #expect(pc.remoteDescription?.sdp == otherClientAnswerSdp)
        #expect(pc.remoteDescription?.type == .answer)
        #expect(pc.signalingState == .stable)
    }

    @Test
    func
        `given offer comes and remote added when add candidate then candidate is added`()
        async throws
    {
        let otherClient = WebRTCClientImpl()
        let otherClientOfferSdp = try await otherClient.createOffer()
        try await sut.setRemoteOffer(otherClientOfferSdp)
        let pc = try #require(mockConnectionFactory.createdConnection)

        await sut.addCandidate(
            IceCandidatePayload(
                candidate:
                    "candidate:1 1 udp 2122260223 192.168.0.4 54348 typ host",
                sdpMid: "0",
                sdpMLineIndex: 0
            )
        )

        try await waitFor { candidateLines(pc.remoteDescription?.sdp) == 1 }
    }

    @Test
    func
        `given remote description is not existed when add candidate then candidate is not added into peer connection`()
        async throws
    {
        let pc = try #require(mockConnectionFactory.createdConnection)

        await sut.addCandidate(
            IceCandidatePayload(
                candidate:
                    "candidate:1 1 udp 2122260223 192.168.0.4 54348 typ host",
                sdpMid: "0",
                sdpMLineIndex: 0
            )
        )

        #expect(candidateLines(pc.remoteDescription?.sdp) == 0)
    }

    @Test
    func
        `given add candidate is skipped when set remote description for offer then candidate is added into peer connection`()
        async throws
    {
        let otherClient = WebRTCClientImpl()
        let otherClientOfferSdp = try await otherClient.createOffer()
        let pc = try #require(mockConnectionFactory.createdConnection)

        await sut.addCandidate(
            IceCandidatePayload(
                candidate:
                    "candidate:1 1 udp 2122260223 192.168.0.4 54348 typ host",
                sdpMid: "0",
                sdpMLineIndex: 0
            )
        )

        try await sut.setRemoteOffer(otherClientOfferSdp)

        try await waitFor { candidateLines(pc.remoteDescription?.sdp) == 1 }
        #expect(candidateLines(pc.remoteDescription?.sdp) == 1)
    }

    @Test
    func
        `given other client's answer comes then add candidate then candidate is added into peer connection`()
        async throws
    {
        let myOffer = try await sut.createOffer()
        let otherClient = WebRTCClientImpl()
        try await otherClient.setRemoteOffer(myOffer)
        let otherClientAnswerSdp = try await otherClient.createAnswer()
        try await sut.setRemoteAnswer(otherClientAnswerSdp)
        let pc = try #require(mockConnectionFactory.createdConnection)

        await sut.addCandidate(
            IceCandidatePayload(
                candidate:
                    "candidate:1 1 udp 2122260223 192.168.0.4 54348 typ host",
                sdpMid: "0",
                sdpMLineIndex: 0
            )
        )

        try await waitFor { candidateLines(pc.remoteDescription?.sdp) == 1 }
        #expect(candidateLines(pc.remoteDescription?.sdp) == 1)
    }

    @Test
    func
        `given add candidate is skipped when set remote description for other client's answer then candidate is added into peer connection`()
        async throws
    {
        let myOffer = try await sut.createOffer()
        let otherClient = WebRTCClientImpl()
        try await otherClient.setRemoteOffer(myOffer)
        let otherClientAnswerSdp = try await otherClient.createAnswer()
        let pc = try #require(mockConnectionFactory.createdConnection)

        await sut.addCandidate(
            IceCandidatePayload(
                candidate:
                    "candidate:1 1 udp 2122260223 192.168.0.4 54348 typ host",
                sdpMid: "0",
                sdpMLineIndex: 0
            )
        )

        try await sut.setRemoteAnswer(otherClientAnswerSdp)

        try await waitFor { candidateLines(pc.remoteDescription?.sdp) == 1 }
        #expect(candidateLines(pc.remoteDescription?.sdp) == 1)
    }

    @Test
    func `when close then state is closed and senders is empty`()
        async throws
    {
        let pc = try #require(mockConnectionFactory.createdConnection)

        sut.close()

        #expect(pc.signalingState == .closed)
        #expect(pc.connectionState == .closed)
        #expect(pc.senders.isEmpty)
        for await _ in sut.events {}
    }
}

func candidateLines(_ sdp: String?) -> Int {
    (sdp ?? "").components(separatedBy: "\r\n").filter {
        $0.hasPrefix("a=candidate:")
    }.count
}
