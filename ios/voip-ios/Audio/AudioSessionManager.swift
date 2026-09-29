//
//  AudioSessionManager.swift
//  voip-ios
//
//  Created by 강준현 on 9/29/26.
//

nonisolated protocol AudioSessionManager {
    func activate() throws
    func deactivate()
}

nonisolated final class RTCAudioSessionManager: AudioSessionManager {
    func activate() throws {
        print("todo")
    }
    
    func deactivate() {
        print("todo")
    }
}
