//
//  Timer.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

import Testing

@testable import voip_ios

@MainActor
struct TimerTests {

    @Test
    func default_timer_seconds_is_60() throws {
        let sut = Timer(limit: 60)

        #expect(sut.time == 60)
    }

    @Test
    func when_start_timer_then_timer_seconds_is_decreased_by_1() async throws {
        let testTimerClock = TestTimerClock()
        let sut = Timer(
            limit: 60,
            timerClock: testTimerClock
        )

        Task {
            await sut.startTimer()
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
