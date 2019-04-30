//
//  ProviderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
@testable import PMVP

class ProviderTests: ProviderBase {

    func testGetEmpty() {
		local.playlists = [:]
		let response = expectation(description: "received")
		provider.object(for: "playlist1", queue: .global()) { (result) in
			switch result {
			case .success(let object):
				if object == nil {
					response.fulfill()
				}
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
    }

	func testGetOne() {
		let playlist = PlaylistProxy(id: "playlist1", name: "example")
		local.playlists = [:]
		local.playlists["playlist1"] = playlist
		let response = expectation(description: "received")
		provider.object(for: "playlist1", queue: .global()) { (result) in
			switch result {
			case .success(let object):
				if let object = object {
					XCTAssertEqual(object.name, playlist.name)
					XCTAssertEqual(object.key, playlist.key)
					response.fulfill()
				}
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
	}

	func testGetTwo() {
		local.playlists = [:]
		for k in (1...2) {
			let p = PlaylistProxy(id: "playlist\(k)", name: "example\(k)")
			local.playlists[p.key] = p
		}
		let response = expectation(description: "received")
		provider.objects(for: ["playlist1", "playlist2"], queue: .global()) { (results) in
			switch results {
			case .success(let objects):
				XCTAssertEqual(objects.count, 2)
				response.fulfill()
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
	}

	func testUpdateOne() {
		local.playlists = [:]
		let p = PlaylistProxy(id: "playlist1", name: "example1")
		local.playlists[p.key] = p
		p.name = "example2"
		let response = expectation(description: "received")
		provider.update(p, queue: .global()) { (result) in
			switch result {
			case .success(let object):
				XCTAssertEqual(object.name, p.name)
				response.fulfill()
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		if let confirm = local.playlists["playlist1"] {
			XCTAssertEqual(confirm.key, p.key)
			XCTAssertEqual(confirm.name, p.name)
		}
		else {
			XCTFail("not found")
		}
	}

	func testUpdateTwo() {
		local.playlists = [:]
		for k in (1...2) {
			let p = PlaylistProxy(id: "playlist\(k)", name: "example\(k)")
			local.playlists[p.key] = p
		}
		let response = expectation(description: "received")
		var map: [String: PlaylistProxy] = [:]
		for k in (1...2) {
			map["playlist\(k)"] = local.playlists["playlist\(k)"]
		}
		map["playlist1"]?.name = "example6"
		map["playlist2"]?.name = "example7"
		var updatedList = [PlaylistProxy](map.values)
		provider.update(updatedList, queue: .global()) { (results) in
			switch results {
			case .success(let objects):
				XCTAssertEqual(objects.count, 2)
				if let first = objects.first {
					XCTAssertEqual(first.name, updatedList[0].name)
				}
				if let last = objects.last {
					XCTAssertEqual(last.name, updatedList[1].name)
				}
				response.fulfill()
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		for k in (1...2) {
			if let confirm = local.playlists["playlist\(k)"] {
				XCTAssertEqual(confirm.key, "playlist\(k)")
				XCTAssertEqual(confirm.name, "example\(k+5)")
			}
			else {
				XCTFail("not found")
			}
		}
	}

	func testDestroy() {
		let playlist = PlaylistProxy(id: "playlist1", name: "example")
		local.playlists = [:]
		local.playlists["playlist1"] = playlist
		let response = expectation(description: "received")
		provider.destroy(playlist, queue: .global()) { (result) in
			switch result {
			case .success(let object):
				XCTAssertEqual(object.name, playlist.name)
				XCTAssertEqual(object.key, playlist.key)
				response.fulfill()
			default:
				break
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		XCTAssertEqual(local.playlists.count, 0)
	}

}
