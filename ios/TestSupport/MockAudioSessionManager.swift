//
//  MockAudioSessionManager.swift
//  voip-ios
//
//  Created by 강준현 on 9/29/26.
//

@testable import voip_ios

class MockAudioSessionManager: AudioSessionManager {
    private(set) var activateCallTimes: Int = 0
    var activateError: MockError?

    func activate() throws {
        activateCallTimes += 1
        if let error = activateError {
            throw error
        }
    }

    private(set) var deactivateCalledTimes: Int = 0

    func deactivate() {
        deactivateCalledTimes += 1
    }
}
