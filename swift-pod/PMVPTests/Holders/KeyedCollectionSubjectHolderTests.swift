//
//  KeyedCollectionSubjectHolderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import RxSwift
@testable import PMVP

class KeyedCollectionSubjectHolderTests: XCTestCase {

	func testKeyedCollectionHolder() {
		let holder = KeyedCollectionSubjectHolder<String, PlaylistProxy>(scheduler: MainScheduler.asyncInstance)
		let empty1Exp = expectation(description: "did receive empty1")
		let nonEmpty1Exp = expectation(description: "did receive non-empty1")
		let empty2Exp = expectation(description: "did receive empty2")
		let nonEmpty2Exp = expectation(description: "did receive non-empty2")
		let key1 = "playlist1"
		let expectedValue1 = "newValue"
		let key2 = "playlist2"
		let expectedValue2 = "oldValue"

		let d1 = holder.subject(for: key1).subscribe(onNext: { actualValue in
			if actualValue.isEmpty {
				empty1Exp.fulfill()
			}
			else {
				nonEmpty1Exp.fulfill()
				if let first = actualValue.first {
					XCTAssertEqual(first.key, key1)
					XCTAssertEqual(first.name, expectedValue1)
				}
			}
		})

		let d2 = holder.subject(for: key2).subscribe(onNext: { actualValue in
			if actualValue.isEmpty {
				empty2Exp.fulfill()
			}
			else {
				nonEmpty2Exp.fulfill()
				if let first = actualValue.first {
					XCTAssertEqual(first.key, key2)
					XCTAssertEqual(first.name, expectedValue2)
				}
			}
		})

		let proxy1 = PlaylistProxy(id: key1, name: expectedValue1)
		holder.notify(for: key1, objects: [proxy1])
		let proxy2 = PlaylistProxy(id: key2, name: expectedValue2)
		holder.notify(for: key2, objects: [proxy2])
		waitForExpectations(timeout: 1.0, handler: nil)

		let d3 = holder.subject(for: key2).skip(1).subscribe(onNext: { _ in
			XCTFail("unexpected value")
		})

		d1.dispose()
		holder.notify(for: key1, objects: [])

		d2.dispose()
		d3.dispose()
		holder.notify(for: key2, objects: [])
	}

}
