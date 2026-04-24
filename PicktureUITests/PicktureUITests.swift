import XCTest

@MainActor
final class PicktureUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
    }

    func testHomeTabIsSelected() throws {
        let homeTab = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(homeTab.isSelected, "Home tab should be selected by default")
    }

    func testCanSwitchTabs() throws {
        let tabBar = app.tabBars.firstMatch

        let cleanTab = tabBar.buttons.element(boundBy: 1)
        cleanTab.tap()

        let settingsTab = tabBar.buttons.element(boundBy: 2)
        settingsTab.tap()

        let homeTab = tabBar.buttons.element(boundBy: 0)
        homeTab.tap()
    }

    func testOnboardingStartCompletesWithoutBottomSheet() throws {
        app.terminate()
        app.launchArguments += ["-onboarding_completed", "NO"]
        app.launch()

        let startButton = app.buttons["Start Pickture"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 4), "Onboarding start button should appear")

        startButton.tap()

        XCTAssertFalse(app.buttons["Continue"].waitForExistence(timeout: 1), "Onboarding should not show a bottom sheet")
    }
}
