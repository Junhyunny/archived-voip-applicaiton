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

    init(signalClient: SignalClient) {
        self.signalClient = signalClient
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

    private func observeSignalEvents() {
        Task {
            for await signalEvent in signalClient.events {
                switch signalEvent {
                case .connected:
                    callStatus = .idle
                case .joined:
                    callStatus = .joined
                case .joinFailed:
                    callStatus = .disconnected
                case .peerJoined:
                    callStatus = .peerJoined
                case .peerLeft:
                    callStatus = .disconnected
                }
            }
        }
    }
}
