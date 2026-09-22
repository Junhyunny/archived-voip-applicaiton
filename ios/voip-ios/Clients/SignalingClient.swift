//
//  SignalingClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

import Foundation

enum CallingStatus {
    case not_connected
    case idle
    case joined
    case join_failed
}

enum ResponseType: String, Codable {
    case joined = "joined"
    case join_failed = "join_failed"
}

enum MessageType: String, Codable {
    case join = "join"
}

enum SignalingError: Error {
    case taskNotCreated
}

struct SignalingResponse: Codable {
    let type: ResponseType
}

struct JoiningMessage: Codable {
    let type: MessageType
    let roomCode: String
}

final class SignalingClient {
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private(set) var callingStatus: CallingStatus = .not_connected

    init(url: URL) {
        self.url = url
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

    private func handleSignalingResponse(_ response: SignalingResponse) {
        switch response.type {
        case .joined:
            self.callingStatus = .joined
        case .join_failed:
            self.callingStatus = .join_failed
        }
    }

    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            return
        }
        do {
            let response = try JSONDecoder().decode(
                SignalingResponse.self,
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
                print("websocket messege receive error \(error)")
            }
            self?.receive(task)
        }
    }

    func connect() async throws {
        let task = URLSession.shared.webSocketTask(with: self.url)
        task.resume()
        try await sendPing(task)
        self.receive(task)
        self.task = task
        self.callingStatus = .idle
    }

    func join(roomCode: String) async throws {
        guard let task = self.task else {
            throw SignalingError.taskNotCreated
        }
        let message = JoiningMessage(
            type: .join,
            roomCode: roomCode
        )
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        try await task.send(.string(string))
    }
}
