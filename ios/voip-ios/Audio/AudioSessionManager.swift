//
//  AudioSessionManager.swift
//  voip-ios
//
//  Created by 강준현 on 9/29/26.
//

import AVFAudio
import WebRTC

nonisolated protocol AudioSessionManager {
    func activate() throws
    func deactivate()
}

nonisolated final class RTCAudioSessionManager: AudioSessionManager {

    private let session = RTCAudioSession.sharedInstance()

    func activate() throws {
        let configuration = RTCAudioSessionConfiguration.webRTC()
        configuration.category = AVAudioSession.Category.playAndRecord.rawValue
        configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
        configuration.categoryOptions = [
            .allowBluetoothHFP,
            .defaultToSpeaker,
        ]

        session.lockForConfiguration()
        defer { session.unlockForConfiguration() }
        try session.setConfiguration(configuration, active: true)
    }

    func deactivate() {
        session.lockForConfiguration()
        defer { session.unlockForConfiguration() }
        do {
            try session.setActive(false)
        } catch {
            print("failed to deactivate audio session", error)
        }
    }
}
