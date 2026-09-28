//
//  MessageType.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

enum SignalRequestType: String, Codable {
    case join = "join"
    case offer = "offer"
    case answer = "answer"
    case iceCandidate = "ice_candidate"
}
