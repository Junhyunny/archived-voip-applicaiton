//
//  WebRTCEvent.swift
//  voip-ios
//
//  Created by 강준현 on 9/28/26.
//

enum WebRTCEvent: Equatable {
    case iceCandidate(IceCandidatePayload)
    case connected
    case disconnected
    case failed
}
