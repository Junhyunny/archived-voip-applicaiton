//
//  SignalingClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import Foundation

protocol SignalClient {
    var events: AsyncStream<SignalEvent> { get }

    func connect() async throws
    func close()
    func join(roomCode: String) async throws
    func send(offer: String) async throws
    func send(answer: String) async throws
    func send(candidate: IceCandidatePayload) async throws
    func leave() async throws
}

final class SignalClientImpl: SignalClient {
    private let url: URL
    private var webSocketTask: URLSessionWebSocketTask?
    private var continuation: AsyncStream<SignalEvent>.Continuation

    var events: AsyncStream<SignalEvent>

    init(url: URL) {
        self.url = url
        var continuation: AsyncStream<SignalEvent>.Continuation!
        self.events = AsyncStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    private func sendPing(_ task: URLSessionWebSocketTask) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            task.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func handleSignalingResponse(_ response: SignalResponse) {
        switch response.type {
        case .joined:
            self.continuation.yield(.joined)
        case .joinFailed:
            self.continuation.yield(.joinFailed)
        case .peerJoined:
            self.continuation.yield(.peerJoined)
        case .peerLeft:
            self.continuation.yield(.peerLeft)
        case .offer:
            guard case .sessionDescription(let payload) = response.payload
            else {
                return
            }
            self.continuation.yield(.offer(payload.sdp))
        case .answer:
            guard case .sessionDescription(let payload) = response.payload
            else {
                return
            }
            self.continuation.yield(.answer(payload.sdp))
        case .iceCandidate:
            guard case .iceCandidate(let payload) = response.payload else {
                return
            }
            self.continuation.yield(.iceCandidate(payload))
        }
    }

    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            return
        }
        do {
            let response = try JSONDecoder().decode(
                SignalResponse.self,
                from: data
            )
            handleSignalingResponse(response)
        } catch {
            print("decode error. raw message: \(data)", error)
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleTextMessage(text)
        case .data:
            // TODO, not handle data case
            break
        @unknown default:
            break
        }
    }

    private func receive(_ task: URLSessionWebSocketTask) {
        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
            case .failure(let error):
                print("websocket message receive error \(error)")
            }
            self?.receive(task)
        }
    }

    func connect() async throws {
        let task = URLSession.shared.webSocketTask(with: self.url)
        task.resume()
        try await sendPing(task)
        self.receive(task)
        self.webSocketTask = task
        self.continuation.yield(.connected)
    }

    func close() {
        self.continuation.finish()
        self.webSocketTask?.cancel()
        self.webSocketTask = nil
    }

    func join(roomCode: String) async throws {
        guard let task = self.webSocketTask else {
            throw SignalError.taskNotCreated
        }
        let message = SignalRequest(
            type: .join,
            payload: JoinPayload(roomCode: roomCode)
        )
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        try await task.send(.string(string))
    }

    private func send<Payload: Encodable>(
        type: SignalRequestType,
        payload: Payload
    ) async throws {
        guard let task = self.webSocketTask else {
            throw SignalError.taskNotCreated
        }
        let message = SignalRequest(
            type: type,
            payload: payload
        )
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        try await task.send(.string(string))
    }

    func send(offer: String) async throws {
        try await send(
            type: .offer,
            payload: SessionDescriptionPayload(sdp: offer)
        )
    }

    func send(answer: String) async throws {
        try await send(
            type: .answer,
            payload: SessionDescriptionPayload(sdp: answer)
        )
    }

    func send(candidate: IceCandidatePayload) async throws {
        try await send(type: .iceCandidate, payload: candidate)
    }

    func leave() async throws {
        try await send(type: .leave, payload: EmptyPayload())
    }
}
