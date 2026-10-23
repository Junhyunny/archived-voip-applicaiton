//
//  TestTimerClock.swift
//  voip-ios
//
//  Created by 강준현 on 9/21/26.
//

@testable import voip_ios

actor TestTimerClock: TimerClock {

    private struct Sleeper {
        let deadline: Duration
        let continuation: CheckedContinuation<Void, Never>
    }

    private var now: Duration = .zero
    private var sleepers: [Sleeper] = []
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func sleepOneSecond() async throws {
        let deadline = now + .seconds(1)
        await withCheckedContinuation { continuation in
            sleepers.append(
                Sleeper(
                    deadline: deadline,
                    continuation: continuation
                )
            )
            for waiter in waiters { waiter.resume() }
            waiters.removeAll()
        }
    }

    func waitForSleeper() async {
        guard sleepers.isEmpty else { return }
        await withCheckedContinuation {
            waiters.append($0)
        }
    }

    func advanceOneSecond() {
        now += .seconds(1)
        let ready = sleepers.filter {
            $0.deadline <= now
        }
        sleepers.removeAll {
            $0.deadline <= now
        }
        for sleeper in ready {
            sleeper.continuation.resume()
        }
    }
}
