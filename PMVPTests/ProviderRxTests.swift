//
//  ProviderRxTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/9/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import RxSwift
@testable import PMVP

class ProviderRxTests: ProviderBase {

    func testNewObjects() {
		local.playlists = [:]

		let emptyExp = expectation(description: "empty")
		_ = provider.object(for: "playlist1").subscribe(onNext: { v0 in
			if v0 == nil {
				emptyExp.fulfill()
			}
			else {
				XCTFail("unexpected nil")
			}
		})

		wait(for: [emptyExp], timeout: 1.0)
	}

	func testEditObjects() {
		local.playlists = [:]

		let notEmptyExp = expectation(description: "no longer empty")
		_ = provider.object(for: "playlist1").subscribe(onNext: { v1 in
			if v1 != nil {
				notEmptyExp.fulfill()
			}
		})

		let updatedExp = expectation(description: "updated")
		let p1 = PlaylistProxy(id: "playlist1", name: "name1")
		provider.update(p1, queue: .global()) { (r1) in
			updatedExp.fulfill()
			XCTAssertEqual(p1.name, r1.name)
			XCTAssertEqual(p1.key, r1.key)
		}

		wait(for: [notEmptyExp, updatedExp], timeout: 1.0)
    }

	func testExisting() {
		let key = "playlist1"
		let name = "Playlist 1"
		var existingData: [String: PlaylistProxy] = [:]
		existingData[key] = PlaylistProxy(id: key, name: name)
		local.playlists = existingData

		let existingExp = expectation(description: "existing")
		_ = provider.object(for: key).subscribe(onNext: { v0 in
			if let v0 = v0 {
				XCTAssertEqual(v0.key, key)
				XCTAssertEqual(v0.name, name)
				existingExp.fulfill()
			}
		})

		wait(for: [existingExp], timeout: 1.0)
	}

}
