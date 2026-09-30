//
//  LaunchUITests.swift
//  voip-iosUITests
//
//  Created by 강준현 on 9/17/26.
//

import XCTest

final class LaunchUITests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_when_launch_then_launch_screen_is_captured() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
