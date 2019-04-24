//
//  SubjectHolderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import RxSwift
@testable import PMVP

class SubjectHolderTests: XCTestCase {

    func testHolder() {
		let holder = SubjectHolder<String>(scheduler: MainScheduler.asyncInstance)
		let nilExp = expectation(description: "did receive nil")
		let nonNilExp = expectation(description: "did receive non-nil")
		let expectedValue = "newValue"
		_ = holder.subject().subscribe(onNext: { actualValue in
			if let actualValue = actualValue {
				XCTAssertEqual(actualValue, expectedValue)
				nonNilExp.fulfill()
			}
			else {
				nilExp.fulfill()
			}
		})
		holder.notify(expectedValue)
		waitForExpectations(timeout: 1.0, handler: nil)
    }

}
