//
//  WebRTCClient.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

import WebRTC

protocol WebRTCClient {
    
}

class WebRTCClientImpl: WebRTCClient {
    let factory = RTCPeerConnectionFactory()
}
