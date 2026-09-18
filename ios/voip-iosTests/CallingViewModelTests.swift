//
//  CallingViewModelTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Testing

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

@MainActor
struct CallingViewModelTests {

    @Test
    func default_timer_seconds_is_60() throws {
        let sut = CallingViewModel()

        #expect(sut.time == 60)
    }

    @Test
    func when_start_timer_then_timer_seconds_is_decreased_by_1() async throws {
        let testTimerClock = TestTimerClock()
        let sut = CallingViewModel(timerClock: testTimerClock)

        Task {
            await sut.startTimer(limit: 60)
        }

        await testTimerClock.waitForSleeper()
        await testTimerClock.advanceOneSecond()
        await testTimerClock.waitForSleeper()
        #expect(sut.time == 59)

        await testTimerClock.advanceOneSecond()
        await testTimerClock.waitForSleeper()
        #expect(sut.time == 58)

        await testTimerClock.advanceOneSecond()
        await testTimerClock.waitForSleeper()
        #expect(sut.time == 57)
    }
}
