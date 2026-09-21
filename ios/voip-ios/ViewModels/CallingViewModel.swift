//
//  CallingViewModel.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Foundation

nonisolated protocol TimerClock {
    func sleepOneSecond() async throws
}

struct RealTimerClock: TimerClock {
    func sleepOneSecond() async throws {
        try await Task.sleep(for: .seconds(1))
    }
}

@Observable
class CallingViewModel {

    private(set) var time: Int
    private let limit: Int
    private let timerClock: TimerClock

    init(limit: Int, timerClock: TimerClock = RealTimerClock()) {
        self.time = limit
        self.limit = limit
        self.timerClock = timerClock
    }

    func startTimer() async {
        time = limit
        while time > 0 {
            do {
                try await timerClock.sleepOneSecond()
            } catch {
                return
            }
            time -= 1
        }
    }
}
