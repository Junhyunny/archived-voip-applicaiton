//
//  ResponseType.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

enum SignalResponseType: String, Codable {
    case joined = "joined"
    case joinFailed = "join_failed"
    case peerJoined = "peer_joined"
}
