//
//  CallingViewModelTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Testing

@testable import voip_ios

@Suite(.timeLimit(.minutes(1)))
@MainActor
struct CallingViewModelTests {

    var mockSignalClient: MockSignalClient
    var mockWebRTCClient: MockWebRTCClient
    var mockAudioSessionManager: MockAudioSessionManager
    var sut: CallingViewModel

    init() throws {
        self.mockSignalClient = MockSignalClient()
        var buildTimes = 0
        let webRTCClient = MockWebRTCClient()
        self.mockWebRTCClient = webRTCClient
        self.mockAudioSessionManager = MockAudioSessionManager()
        self.sut = CallingViewModel(
            signalClient: mockSignalClient,
            buildWebRTCClient: {
                buildTimes += 1
                if buildTimes == 1 {
                    return webRTCClient
                }
                return MockWebRTCClient()
            },
            audioSessionManager: mockAudioSessionManager
        )
    }

    @Test func `initial call status is unconnected`() async throws {
        #expect(sut.callStatus == .unconnected)
    }

    @Test
    func
        `when start call then signalClinet's connect, join funciton are called`()
        async throws
    {
        await sut.startCall(roomCode: "1234")

        #expect(mockAudioSessionManager.activateCallTimes == 0)
        #expect(mockSignalClient.connectCalledTimes == 1)
        #expect(mockSignalClient.joinCalledTimes == 1)
        #expect(mockSignalClient.joinRoomCode == "1234")
    }

    @Test
    func
        `when start call then signalClinet's signal event is observed`()
        async throws
    {
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(.connected)
        try await waitFor {
            sut.callStatus == .idle
        }
        mockSignalClient.continuation.yield(.joined)
        try await waitFor {
            sut.callStatus == .joined
        }
        mockSignalClient.continuation.yield(.joinFailed)
        try await waitFor {
            sut.callStatus == .disconnected
        }
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor {
            sut.callStatus == .negotiating
        }
        mockSignalClient.continuation.yield(.peerLeft)
        try await waitFor {
            sut.callStatus == .disconnected
        }
    }

    @Test
    func
        `given connect throws error when start call then call status is disconnected`()
        async throws
    {
        mockSignalClient.connectError = MockError.sample

        await sut.startCall(roomCode: "1234")

        #expect(sut.callStatus == .disconnected)
    }

    @Test
    func
        `given join throws error when start call then call status is disconnected`()
        async throws
    {
        mockSignalClient.joinError = MockError.sample

        await sut.startCall(roomCode: "1234")

        #expect(sut.callStatus == .disconnected)
    }

    @Test
    func
        `given start call when peerJoined event is received then start negotiating`()
        async throws
    {
        mockWebRTCClient.createOfferReturn = "session document payload"
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(.peerJoined)

        try await waitFor {
            sut.callStatus == .negotiating
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.createOfferCallTimes == 1)
        #expect(mockSignalClient.sendOfferCallTimes == 1)
        #expect(mockSignalClient.sendOfferSdp == "session document payload")
    }

    @Test
    func
        `given negotiating in creating offer when create offer throws error then call status is disconnected`()
        async throws
    {
        mockWebRTCClient.createOfferError = .sample
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(.peerJoined)

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.createOfferCallTimes == 1)
        #expect(mockSignalClient.sendOfferCallTimes == 0)
    }

    @Test
    func
        `given negotiating in creating offer when send offer throws error then call status is disconnected`()
        async throws
    {
        mockSignalClient.sendOfferError = .sample
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(.peerJoined)

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.createOfferCallTimes == 1)
        #expect(mockSignalClient.sendOfferCallTimes == 1)
    }

    @Test
    func
        `given start call when offer event is received then accept offer and send answer`()
        async throws
    {
        mockWebRTCClient.acceptOfferReturn = "session document payload"
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(
            .offer("offer session document payload")
        )

        try await waitFor {
            sut.callStatus == .negotiating
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
        #expect(
            mockWebRTCClient.acceptOfferSdp
                == "offer session document payload"
        )
        #expect(mockSignalClient.sendAnswerCallTimes == 1)
        #expect(mockSignalClient.sendAnswerSdp == "session document payload")
    }

    @Test
    func
        `given negotiating in accepting offer when acceptOffer throws error then call status is disconnected`()
        async throws
    {
        mockWebRTCClient.acceptOfferError = .sample
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(
            .offer("offer session document payload")
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
        #expect(
            mockWebRTCClient.acceptOfferSdp == "offer session document payload"
        )
        #expect(mockSignalClient.sendAnswerCallTimes == 0)
    }

    @Test
    func
        `given negotiating in accepting offer when sendAnswer throws error then call status is disconnected`()
        async throws
    {
        mockWebRTCClient.acceptOfferReturn = "session document payload"
        mockSignalClient.sendAnswerError = .sample
        await sut.startCall(roomCode: "1234")

        mockSignalClient.continuation.yield(
            .offer("offer session document payload")
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
        #expect(
            mockWebRTCClient.acceptOfferSdp == "offer session document payload"
        )
        #expect(mockSignalClient.sendAnswerCallTimes == 1)
        #expect(mockSignalClient.sendAnswerSdp == "session document payload")
    }

    @Test
    func
        `given sending offer when answer event is received then accept answer`()
        async throws
    {
        mockWebRTCClient.createOfferReturn = "offer session document payload"
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(
            .peerJoined
        )
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockSignalClient.continuation.yield(
            .answer("answer session document payload")
        )

        try await waitFor {
            mockWebRTCClient.setRemoteAnswerCalled == 1
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.createOfferCallTimes == 1)
        #expect(mockWebRTCClient.setRemoteAnswerCalled == 1)
        #expect(
            mockWebRTCClient.setRemoteAnswerSdp
                == "answer session document payload"
        )
        #expect(mockSignalClient.sendOfferCallTimes == 1)
        #expect(
            mockSignalClient.sendOfferSdp == "offer session document payload"
        )
    }

    @Test
    func
        `given accepting answer when setRemoteAnswer throws error then call status is disconnected`()
        async throws
    {
        mockWebRTCClient.createOfferReturn = "offer session document payload"
        mockWebRTCClient.setRemoteAnswerError = .sample
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(
            .peerJoined
        )
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockSignalClient.continuation.yield(
            .answer("answer session document payload")
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.createOfferCallTimes == 1)
        #expect(mockWebRTCClient.setRemoteAnswerCalled == 1)
        #expect(
            mockWebRTCClient.setRemoteAnswerSdp
                == "answer session document payload"
        )
        #expect(mockSignalClient.sendOfferCallTimes == 1)
        #expect(
            mockSignalClient.sendOfferSdp == "offer session document payload"
        )
    }

    @Test
    func
        `given accepted offer when iceCandidate event is received then add candidates into WebRTCClient`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.offer("session document payload"))
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockSignalClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            mockWebRTCClient.addCandidateCalled == 1
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
        #expect(mockWebRTCClient.addCandidateCalled == 1)
        #expect(
            mockWebRTCClient.addCandidateCandidates == [
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            ]
        )
    }

    @Test
    func
        `given add ice candidates when addIceCandidate throws error then call status is disconnected`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.offer("session document payload"))
        mockWebRTCClient.addCandidateError = .sample
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockSignalClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
    }

    @Test
    func
        `given iceCandidate event is received early when offer event is received lately then add candidates in accept offer phase`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        mockSignalClient.continuation.yield(.offer("session document payload"))

        try await waitFor {
            sut.callStatus == .negotiating
        }
        try await waitFor {
            mockWebRTCClient.addCandidateCalled == 1
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 1)
        #expect(mockWebRTCClient.addCandidateCalled == 1)
        #expect(
            mockWebRTCClient.addCandidateCandidates == [
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            ]
        )
    }

    @Test
    func
        `given iceCandidate event is received early when offer event is received two times lately then do not add previous pending candidates again`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        mockSignalClient.continuation.yield(.offer("session document payload"))
        mockSignalClient.continuation.yield(.offer("session document payload"))

        try await waitFor {
            sut.callStatus == .negotiating
        }
        try await waitFor {
            mockWebRTCClient.acceptOfferCalled == 2
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockWebRTCClient.acceptOfferCalled == 2)
        #expect(mockWebRTCClient.addCandidateCalled == 1)
        #expect(
            mockWebRTCClient.addCandidateCandidates == [
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            ]
        )
    }

    @Test
    func
        `given starting negotiating when iceCandidate event is received from WebRTC then send candidates to other peer`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            mockSignalClient.sendCandidateCallTimes == 1
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockSignalClient.sendCandidateCallTimes == 1)
        #expect(
            mockSignalClient.sendCandidateCnadidate
                == IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
        )
    }

    @Test
    func
        `given starting negotiating when sendIceCandidate throws error then call status is disconnected`()
        async throws
    {
        mockSignalClient.sendCandidateError = .sample
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(sut.callStatus == .disconnected)
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockSignalClient.sendCandidateCallTimes == 1)
        #expect(
            mockSignalClient.sendCandidateCnadidate
                == IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
        )
    }

    @Test
    func
        `given accepting offer when iceCandidate event is received from WebRTC then send candidates to other peer`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.offer("session document payload"))
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            mockSignalClient.sendCandidateCallTimes == 1
        }
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockSignalClient.sendCandidateCallTimes == 1)
        #expect(
            mockSignalClient.sendCandidateCnadidate
                == IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
        )
    }

    @Test
    func
        `given accepting offer when sendIceCandidate throws error then call status is disconnected`()
        async throws
    {
        mockSignalClient.sendCandidateError = .sample
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.offer("session document payload"))
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
            )
        )

        try await waitFor {
            sut.callStatus == .disconnected
        }
        #expect(sut.callStatus == .disconnected)
        #expect(mockAudioSessionManager.activateCallTimes == 1)
        #expect(mockSignalClient.sendCandidateCallTimes == 1)
        #expect(
            mockSignalClient.sendCandidateCnadidate
                == IceCandidatePayload(
                    candidate: "candidate",
                    sdpMid: "sdpMid",
                    sdpMLineIndex: 0
                )
        )
    }

    @Test
    func
        `given starting negotiating when connected event is received from WebRTC then call status is connected`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .connected
        )

        try await waitFor {
            sut.callStatus == .connected
        }
    }

    @Test
    func
        `given accepting offer when connected event is received from WebRTC then call status is connected`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.offer("session document payload"))
        try await waitFor {
            sut.callStatus == .negotiating
        }

        mockWebRTCClient.continuation.yield(
            .connected
        )

        try await waitFor {
            sut.callStatus == .connected
        }
    }

    @Test
    func
        `given starting negotiating when disconnected or failed event is received from WebRTC then call status is disconnected`()
        async throws
    {
        for tc in [WebRTCEvent.disconnected, WebRTCEvent.failed] {
            await sut.startCall(roomCode: "1234")
            mockSignalClient.continuation.yield(.peerJoined)
            try await waitFor {
                sut.callStatus == .negotiating
            }

            mockWebRTCClient.continuation.yield(tc)

            try await waitFor {
                sut.callStatus == .disconnected
            }
        }
    }

    @Test
    func
        `given accepting offer when disconnected or failed event is received from WebRTC then call status is disconnected`()
        async throws
    {
        for tc in [WebRTCEvent.disconnected, WebRTCEvent.failed] {
            await sut.startCall(roomCode: "1234")
            mockSignalClient.continuation.yield(
                .offer("session document payload")
            )
            try await waitFor {
                sut.callStatus == .negotiating
            }

            mockWebRTCClient.continuation.yield(tc)

            try await waitFor {
                sut.callStatus == .disconnected
            }
        }
    }

    @Test
    func `when close then send leave message to server`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor { sut.callStatus == .negotiating }

        await sut.close()

        try await waitFor {
            mockSignalClient.leaveCallTimes == 1
        }
        #expect(mockSignalClient.leaveCallTimes == 1)
    }

    @Test
    func `when close then audio session and peer connection are torn down`()
        async throws
    {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor { sut.callStatus == .negotiating }

        await sut.close()

        #expect(mockAudioSessionManager.deactivateCalledTimes == 1)
        #expect(mockSignalClient.closeCalledTimes == 1)
        #expect(mockWebRTCClient.closeCalledTimes == 1)
    }

    @Test func `when close then signal events are ignored`() async throws {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.joined)
        try await waitFor { sut.callStatus == .joined }

        await sut.close()
        
        try? await Task.sleep(for: .milliseconds(100))
        mockSignalClient.continuation.yield(.peerJoined)
        #expect(sut.callStatus == .joined)
    }

    @Test func `when close then webRTC events are ignored`() async throws {
        await sut.startCall(roomCode: "1234")
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitFor { sut.callStatus == .negotiating }

        await sut.close()

        try? await Task.sleep(for: .milliseconds(100))
        mockWebRTCClient.continuation.yield(
            .connected
        )
        #expect(sut.callStatus == .negotiating)
    }
}
