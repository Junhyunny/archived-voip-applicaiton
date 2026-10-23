//
//  WebRTCClient+Delegate.swift
//  voip-ios
//
//  Created by 강준현 on 9/28/26.
//

import WebRTC

extension WebRTCClientImpl: RTCPeerConnectionDelegate {
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {
        print("signaling state:", stateChanged.rawValue)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {
        print("remote stream added, audio tracks:", stream.audioTracks.count)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {
        print("remote stream removed")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print(
            "peer connection is finished at the first time. no re-negotiation"
        )
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        print("ice connection state:", newState.rawValue)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
        print("ice gathering state:", newState.rawValue)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {
        continuation.yield(
            .iceCandidate(
                IceCandidatePayload(
                    candidate: candidate.sdp,
                    sdpMid: candidate.sdpMid,
                    sdpMLineIndex: candidate.sdpMLineIndex
                )
            )
        )
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCPeerConnectionState
    ) {
        switch newState {
        case .connected:
            continuation.yield(.connected)
        case .new, .connecting:
            break
        case .disconnected, .closed:
            continuation.yield(.disconnected)
        case .failed:
            continuation.yield(.failed)
        @unknown default:
            break
        }
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {
        print("ice candidates removed:", candidates.count)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {
        print("data channel is not used")
    }
}
