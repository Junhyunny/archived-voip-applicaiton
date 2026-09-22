//
//  CallingViewModelTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Testing

@testable import voip_ios

@MainActor
struct CallingViewModelTests {

    var mockSignalClient: MockSignalClient
    var sut: CallingViewModel

    init() throws {
        self.mockSignalClient = MockSignalClient()
        self.sut = CallingViewModel(signalClient: mockSignalClient)
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
        try await waitUntil(timeout: Duration.seconds(5)) {
            sut.callStatus == .idle
        }
        mockSignalClient.continuation.yield(.joined)
        try await waitUntil(timeout: Duration.seconds(5)) {
            sut.callStatus == .joined
        }
        mockSignalClient.continuation.yield(.joinFailed)
        try await waitUntil(timeout: Duration.seconds(5)) {
            sut.callStatus == .disconnected
        }
        mockSignalClient.continuation.yield(.peerJoined)
        try await waitUntil(timeout: Duration.seconds(5)) {
            sut.callStatus == .peerJoined
        }
        mockSignalClient.continuation.yield(.peerLeft)
        try await waitUntil(timeout: Duration.seconds(5)) {
            sut.callStatus == .disconnected
        }
    }

    @Test
    func
        `given connect throws error when start call then call status is disconnected`()
        async throws
    {
        mockSignalClient.connectError = MockSignalError.sample

        await sut.startCall(roomCode: "1234")

        #expect(sut.callStatus == .disconnected)
    }
    
    @Test
    func
        `given join throws error when start call then call status is disconnected`()
        async throws
    {
        mockSignalClient.joinError = MockSignalError.sample

        await sut.startCall(roomCode: "1234")

        #expect(sut.callStatus == .disconnected)
    }
}
