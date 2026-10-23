//
//  CountDownTimerTests.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

import Testing

@testable import voip_ios

@Suite(.timeLimit(.minutes(1)))
@MainActor
struct CountDownTimerTests {

    @Test
    func `given limit is 60 when init timer then time is 60`() throws {
        let sut = CountDownTimer(limit: 60)

        #expect(sut.time == 60)
    }

    @Test
    func `when start timer then time is decreased by 1 every second`()
        async throws
    {
        let testTimerClock = TestTimerClock()
        let sut = CountDownTimer(
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
