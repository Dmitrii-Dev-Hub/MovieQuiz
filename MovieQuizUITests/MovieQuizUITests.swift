//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by 0 on 1/2/2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
        
    }
    
    override func tearDownWithError() throws {
        // app = nil
        app.terminate()
    }
    
    @MainActor
    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()
        
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(
            macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            
            measure(
                metrics: [XCTApplicationLaunchMetric()]) {
                    XCUIApplication().launch()
                }
        }
    }
    
    func testYesButton() {
        
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(
            firstPoster.waitForExistence(timeout: 5))
        let firstPosterData =
        firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        var secondPosterData: Data?
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "NOT SELF == %@", firstPosterData as CVarArg),
            object: { secondPosterData }
        )
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        if result == .completed {
            secondPosterData = app.images["Poster"].screenshot().pngRepresentation
        } else {
            XCTFail("Постер не поменялся")
        }
        
        XCTAssertNotEqual(firstPosterData, secondPosterData!)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(
            firstPoster.waitForExistence(timeout: 5))
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        var secondPosterData: Data?
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "NOT SELF == %@", firstPosterData as CVarArg),
            object: { secondPosterData }
        )
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        if result == .completed {
            secondPosterData = app.images["Poster"].screenshot().pngRepresentation
        } else {
            XCTFail("Постер не поменялся")
        }
        
        XCTAssertNotEqual(firstPosterData, secondPosterData!)
    }
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["alert"]
        let alertButton = alert.buttons["alertAction"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alertButton.label == "Сыграть еще раз")
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
}
