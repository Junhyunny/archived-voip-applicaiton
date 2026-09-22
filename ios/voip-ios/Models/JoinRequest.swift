//
//  JoiningRequest.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

struct JoinRequest: Codable {
    let type: SignalRequestType
    let roomCode: String
}
