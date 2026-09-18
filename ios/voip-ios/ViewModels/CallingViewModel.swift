//
//  CallingViewModel.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Foundation

protocol TimerClock {
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
    private let timerClock: TimerClock

    init(time: Int = 60, timerClock: TimerClock = RealTimerClock()) {
        self.time = time
        self.timerClock = timerClock
    }

    func startTimer(limit: Int) async {
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
