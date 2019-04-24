//
//  KeyedSubjectHolderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import RxSwift
@testable import PMVP

class KeyedSubjectHolderTests: XCTestCase {

	func testKeyedHolder() {
		let holder = KeyedSubjectHolder<String, PlaylistProxy>(scheduler: MainScheduler.asyncInstance)
		let nilExp = expectation(description: "did receive nil")
		let nonNilExp = expectation(description: "did receive non-nil")
		let key = "playlist1"
		let expectedValue = "newValue"
		_ = holder.subject(for: key).subscribe(onNext: { actualValue in
			if let actualValue = actualValue {
				XCTAssertEqual(actualValue.name, expectedValue)
				nonNilExp.fulfill()
			}
			else {
				nilExp.fulfill()
			}
		})
		let d2 = holder.subject(for: "playlist2").skip(1).subscribe(onNext: { _ in
			XCTFail("unexpected value")
		})
		let proxy1 = PlaylistProxy(id: key, name: expectedValue)
		holder.notify(proxy1)
		d2.dispose()

		let proxy2 = PlaylistProxy(id: "playlist2", name: "Another Playlist")
		holder.notify(proxy2)
		waitForExpectations(timeout: 1.0, handler: nil)
	}

}
