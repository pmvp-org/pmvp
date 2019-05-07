//
//  ItemViewTests.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 5/6/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest

class ItemViewTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
    }

    func testOneItem() {
		let app = XCUIApplication()
		app.launchArguments = ["UseMocks", "HasOneItem"]
		app.launch()

		XCTAssertTrue(app.navigationBars["Items"].exists)
		XCTAssertEqual(app.tables.cells.count, 1)
		app.tables.cells.firstMatch.tap()
		XCTAssertTrue(app.navigationBars["Edit Item"].exists)
		XCTAssertTrue(app.navigationBars["Edit Item"].buttons["Cancel"].exists)
		app.navigationBars["Edit Item"].buttons["Cancel"].tap()
		XCTAssertTrue(app.navigationBars["Items"].exists)
		app.tables.cells.firstMatch.tap()
		XCTAssertTrue(app.textFields["valueText"].exists)
		XCTAssertTrue(app.staticTexts["valueLabel"].exists)
		XCTAssertEqual(app.textFields["valueText"].value as? String ?? "", "eggs")
	}

	func testMultipleItems() {
		let app = XCUIApplication()
		app.launchArguments = ["UseMocks", "HasItems"]
		app.launch()

		XCTAssertTrue(app.navigationBars["Items"].exists)
		XCTAssertEqual(app.tables.cells.count, 2)
		app.tables.cells.firstMatch.tap()
		XCTAssertTrue(app.navigationBars["Edit Item"].exists)
		XCTAssertTrue(app.navigationBars["Edit Item"].buttons["Cancel"].exists)
		app.navigationBars["Edit Item"].buttons["Cancel"].tap()
		XCTAssertTrue(app.navigationBars["Items"].exists)
		app.tables.cells.firstMatch.tap()
		XCTAssertTrue(app.textFields["valueText"].exists)
		XCTAssertTrue(app.staticTexts["valueLabel"].exists)
	}

}
