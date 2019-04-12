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

    func testObservable() {
		local.playlists = [:]

		let emptyExp = expectation(description: "empty")
		let d0 = provider.object(for: "playlist1").subscribe(onNext: { v0 in
			if v0 == nil {
				emptyExp.fulfill()
			}
			else {
				XCTFail("unexpected nil")
			}
		})

		wait(for: [emptyExp], timeout: 1.0)
		d0.dispose()

		let notEmptyExp = expectation(description: "no longer empty")
		_ = provider.object(for: "playlist1").subscribe(onNext: { v1 in
			if v1 != nil {
				notEmptyExp.fulfill()
			}
		})

		let updatedExp = expectation(description: "updated")
		let p1 = PlaylistProxy(playlistId: "playlist1", name: "name1")
		provider.update(p1, queue: .global()) { (r1) in
			updatedExp.fulfill()
			XCTAssertEqual(p1.name, r1.name)
			XCTAssertEqual(p1.playlistId, r1.playlistId)
		}

		wait(for: [notEmptyExp, updatedExp], timeout: 1.0)
    }

}
