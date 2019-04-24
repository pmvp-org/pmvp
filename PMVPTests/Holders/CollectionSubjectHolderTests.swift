//
//  CollectionSubjectHolderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import RxSwift
@testable import PMVP

class CollectionSubjectHolderTests: XCTestCase {

	func testCollectionHolder() {
		let holder = CollectionSubjectHolder<PlaylistProxy>(scheduler: MainScheduler.asyncInstance)
		let emptyExp = expectation(description: "did receive empty")
		let nonEmptyExp = expectation(description: "did receive non-empty")
		let key = "playlist1"
		let expectedValue = "newValue"
		_ = holder.subject().subscribe(onNext: { actualValue in
			if actualValue.isEmpty {
				emptyExp.fulfill()
			}
			else {
				XCTAssertEqual(actualValue.count, 1)
				nonEmptyExp.fulfill()
			}
		})
		let proxy = PlaylistProxy(id: key, name: expectedValue)
		let results: [PlaylistProxy] = [proxy]
		holder.notify(results)
		waitForExpectations(timeout: 1.0, handler: nil)
	}

}
