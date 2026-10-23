//
//  FakeRemotePeer.swift
//  voip-ios
//
//  Created by 강준현 on 9/29/26.
//

import Foundation
import WebRTC

final class FakeRemotePeer: NSObject, RTCPeerConnectionDelegate {

    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        return RTCPeerConnectionFactory()
    }()

    private let constraints = RTCMediaConstraints(
        mandatoryConstraints: nil,
        optionalConstraints: nil
    )

    private var peerConnection: RTCPeerConnection!
    private let send: @Sendable (String) -> Void

    init(
        send: @escaping @Sendable (String) -> Void
    ) {
        self.send = send
        super.init()
        let configuration = RTCConfiguration()
        configuration.sdpSemantics = .unifiedPlan
        configuration.continualGatheringPolicy = .gatherContinually
        peerConnection = Self.factory.peerConnection(
            with: configuration,
            constraints: constraints,
            delegate: self
        )!
        peerConnection.add(
            Self.factory.audioTrack(withTrackId: "remote0"),
            streamIds: ["remoteStream"]
        )
    }

    func handle(_ text: String) async {
        guard let data = text.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any],
            let type = json["type"] as? String
        else { return }
        let payload = json["payload"] as? [String: Any] ?? [:]

        switch type {
        case "join":
            send(frame("joined"))
            send(frame("peer_joined"))
        case "offer":
            guard let sdp = payload["sdp"] as? String else { return }
            await acceptOffer(sdp)
        case "ice_candidate":
            addCandidate(payload)
        case "leave":
            send(frame("peer_left"))
        default:
            break
        }
    }

    private func acceptOffer(_ sdp: String) async {
        do {
            try await peerConnection.setRemoteDescription(
                RTCSessionDescription(type: .offer, sdp: sdp)
            )
            let answer = try await peerConnection.answer(for: constraints)
            try await peerConnection.setLocalDescription(answer)
            send(frame("answer", ["sdp": answer.sdp]))
        } catch {
            print("FakeRemotePeer 협상 실패:", error)
        }
    }

    private func addCandidate(_ payload: [String: Any]) {
        guard let candidate = payload["candidate"] as? String else { return }
        peerConnection.add(
            RTCIceCandidate(
                sdp: candidate,
                sdpMLineIndex: Int32(payload["sdpMLineIndex"] as? Int ?? 0),
                sdpMid: payload["sdpMid"] as? String
            )
        ) { error in if let error { print("후보 추가 실패:", error) } }
    }

    private func frame(_ type: String, _ payload: [String: Any]? = nil)
        -> String
    {
        var json: [String: Any] = ["type": type]
        if let payload { json["payload"] = payload }
        return String(
            decoding: try! JSONSerialization.data(withJSONObject: json),
            as: UTF8.self
        )
    }

    func peerConnection(
        _ pc: RTCPeerConnection,
        didGenerate c: RTCIceCandidate
    ) {
        send(
            frame(
                "ice_candidate",
                [
                    "candidate": c.sdp,
                    "sdpMid": c.sdpMid ?? "0",
                    "sdpMLineIndex": Int(c.sdpMLineIndex),
                ]
            )
        )
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {
    }

    func peerConnection(
        _ pc: RTCPeerConnection,
        didChange s: RTCPeerConnectionState
    ) {
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
    }
}
