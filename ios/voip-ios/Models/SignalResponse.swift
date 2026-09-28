//
//  SignalingResponse.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

enum SignalResponsePayload: Equatable {
    case sessionDescription(SessionDescriptionPayload)
    case iceCandidate(IceCandidatePayload)
}

struct SignalResponse: Decodable {
    let type: SignalResponseType
    let payload: SignalResponsePayload?

    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SignalResponseType.self, forKey: .type)
        self.type = type
        switch type {
        case .offer, .answer:
            self.payload = .sessionDescription(
                try container.decode(
                    SessionDescriptionPayload.self,
                    forKey: .payload
                )
            )
        case .iceCandidate:
            self.payload = .iceCandidate(
                try container.decode(
                    IceCandidatePayload.self,
                    forKey: .payload
                )
            )
        case .joined, .joinFailed, .peerJoined, .peerLeft:
            self.payload = nil
        }
    }
}
