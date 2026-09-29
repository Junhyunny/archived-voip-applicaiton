//
//  CallStatus+.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

extension CallStatus {
    var joinSignaling: Bool {
        switch self {
        case .joined, .negotiating, .connected:
            true
        case .unconnected, .idle, .disconnected:
            false
        }
    }

    var peerJoined: Bool {
        switch self {
        case .negotiating, .connected:
            true
        case .unconnected, .idle, .joined, .disconnected:
            false
        }
    }
}
