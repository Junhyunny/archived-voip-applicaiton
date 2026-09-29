//
//  CallingViewModel.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Foundation

@Observable
class CallingViewModel {
    private(set) var callStatus: CallStatus = .unconnected
    private var signalClient: SignalClient
    private var buildWebRTCClient: () -> WebRTCClient
    private var audioSessionManager: AudioSessionManager
    private var webRTCClient: WebRTCClient?
    private var pendingIceCandidates: [IceCandidatePayload] = []
    private var signalTask: Task<Void, Never>?
    private var webRTCTask: Task<Void, Never>?
    private var isClosed = false

    init(
        signalClient: SignalClient,
        buildWebRTCClient: @escaping () -> WebRTCClient = {
            WebRTCClientImpl()
        },
        audioSessionManager: AudioSessionManager = RTCAudioSessionManager()
    ) {
        self.signalClient = signalClient
        self.buildWebRTCClient = buildWebRTCClient
        self.audioSessionManager = audioSessionManager
    }

    func startCall(roomCode: String) async {
        do {
            try await signalClient.connect()
            try await signalClient.join(roomCode: roomCode)
        } catch {
            print("error occurs: ", error)
            self.callStatus = .disconnected
            return
        }
        observeSignalEvents()
    }

    func close() async {
        guard !isClosed else { return }
        isClosed = true

        signalTask?.cancel()
        signalTask = nil
        webRTCTask?.cancel()
        webRTCTask = nil

        try? await signalClient.leave()
        signalClient.close()

        webRTCClient?.close()
        webRTCClient = nil
        pendingIceCandidates.removeAll()
        audioSessionManager.deactivate()
    }

    private func prepareWebRTC() -> WebRTCClient {
        if let webRTCClient {
            return webRTCClient
        }
        do {
            try audioSessionManager.activate()
        } catch {
            print("failed to activate audio session", error)
        }
        let client = buildWebRTCClient()
        self.webRTCClient = client
        observeWebRTCEvent(client: client)
        return client
    }

    private func sendCandidate(candidate: IceCandidatePayload) async {
        do {
            try await signalClient.send(candidate: candidate)
        } catch {
            callStatus = .disconnected
        }
    }

    private func observeWebRTCEvent(client: WebRTCClient) {
        webRTCTask = Task {
            for await event in client.events {
                switch event {
                case .iceCandidate(let payload):
                    await sendCandidate(candidate: payload)
                case .connected:
                    callStatus = .connected
                case .disconnected, .failed:
                    callStatus = .disconnected
                }
            }
        }
    }

    private func addPendingCandidates(client: WebRTCClient) async throws {
        defer {
            pendingIceCandidates.removeAll()
        }
        for candidate in pendingIceCandidates {
            try await client.addCandidate(candidate)
        }
    }

    private func startNegotiating() async {
        let client = prepareWebRTC()
        callStatus = .negotiating
        do {
            let sdp = try await client.createOffer()
            try await signalClient.send(offer: sdp)
        } catch {
            callStatus = .disconnected
        }
    }

    private func acceptOffer(offerSdp: String) async {
        let client = prepareWebRTC()
        callStatus = .negotiating
        do {
            let sdp = try await client.acceptOffer(offerSdp)
            try await signalClient.send(answer: sdp)
            try await addPendingCandidates(client: client)
        } catch {
            callStatus = .disconnected
        }
    }

    private func acceptAnswer(answerSdp: String) async {
        guard let webRTCClient else {
            return
        }
        do {
            try await webRTCClient.setRemoteAnswer(answerSdp)
        } catch {
            callStatus = .disconnected
        }
    }

    private func addIceCandidate(candidate: IceCandidatePayload) async {
        guard let webRTCClient else {
            pendingIceCandidates.append(candidate)
            return
        }
        do {
            try await webRTCClient.addCandidate(candidate)
        } catch {
            callStatus = .disconnected
        }
    }

    private func observeSignalEvents() {
        signalTask = Task {
            for await signalEvent in signalClient.events {
                switch signalEvent {
                case .connected:
                    callStatus = .idle
                case .joined:
                    callStatus = .joined
                case .joinFailed:
                    callStatus = .disconnected
                case .peerLeft:
                    callStatus = .disconnected
                case .peerJoined:
                    await startNegotiating()
                case .offer(let payload):
                    await acceptOffer(offerSdp: payload)
                case .answer(let payload):
                    await acceptAnswer(answerSdp: payload)
                case .iceCandidate(let payload):
                    await addIceCandidate(candidate: payload)
                }
            }
        }
    }
}
