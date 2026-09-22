//
//  Utils.swift
//  voip-ios
//
//  Created by 강준현 on 9/22/26.
//

func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping () async -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while clock.now < deadline {
        if await condition() {
            return
        }
        try await Task.sleep(for: .milliseconds(10))
    }
    throw WaitError.timeout
}

enum WaitError: Error {
    case timeout
}
