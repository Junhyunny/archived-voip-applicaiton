//
//  SignalRequest.swift
//  voip-ios
//
//  Created by 강준현 on 9/24/26.
//

struct SignalRequest<Payload: Encodable>: Encodable {
    let type: SignalRequestType
    let payload: Payload
}
