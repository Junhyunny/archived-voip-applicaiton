//
//  AppConfiguration.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import Foundation
import SwiftUI

struct AppConfiguration {
    var timeLimitSeconds: Int = 60
    var signalingURL: URL = URL(string: "ws://localhost:8080/signaling")!

    static func fromLaunchEnvironment() -> AppConfiguration {
        var configuration = AppConfiguration()
        #if DEBUG
            let environment = ProcessInfo.processInfo.environment
            if let timeLimitSeconds = environment["CALL_TIME_LIMIT_SECONDS"],
                let seconds = Int(timeLimitSeconds), seconds > 0
            {
                configuration.timeLimitSeconds = seconds
            }
            if let signalingURL = environment["SIGNALING_URL"],
                let url = URL(string: signalingURL)
            {
                configuration.signalingURL = url
            }
        #endif
        return configuration
    }
}

private struct AppConfigurationKey: EnvironmentKey {
    static let defaultValue = AppConfiguration()
}

extension EnvironmentValues {
    var appConfig: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
    }
}
