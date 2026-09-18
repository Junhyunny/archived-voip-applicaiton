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

    static func fromLaunchEnvironment() -> AppConfiguration {
        var configration = AppConfiguration()
        #if DEBUG
            if let timeLimitSeconds = ProcessInfo.processInfo.environment[
                "CALL_TIME_LIMIT_SECONDS"
            ],
                let seconds = Int(timeLimitSeconds), seconds > 0
            {
                configration.timeLimitSeconds = seconds
            }
        #endif
        return configration
    }
}

private struct AppConfigurationKey: EnvironmentKey {
    static let defaultValue = AppConfiguration()
}

extension EnvironmentValues {
    var appConfiguration: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
    }
}
