//
//  SignalEvent.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

enum SignalEvent {
    case connected
    case joined
    case joinFailed
    case peerJoined
    // case offer(String)
    // case answer(String)
    // case iceCandidate(IceCandidate)
    case peerLeft
}
