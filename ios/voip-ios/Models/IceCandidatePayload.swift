//
//  IceCandidatePayload.swift
//  voip-ios
//
//  Created by 강준현 on 9/28/26.
//

struct IceCandidatePayload: Codable, Equatable {
    let candidate: String
    let sdpMid: String?
    let sdpMLineIndex: Int32
}
