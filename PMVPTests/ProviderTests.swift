//
//  ProviderTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
@testable import PMVP

class ProviderTests: XCTestCase {

	var provider: PlaylistProvider!
	var local: PlaylistLocalStorage!
	var remote: PlaylistRemoteStorage!
	let localConverter = PlaylistLocalConverter()
	let remoteConverter = PlaylistRemoteConverter()

    override func setUp() {
		local = PlaylistLocalStorage(converter: localConverter)
		remote = PlaylistRemoteStorage(converter: remoteConverter)
		provider = PlaylistProvider(queueName: "queue.playlist", localStorage: local, remoteStorage: remote)
    }

    override func tearDown() {
    }

    func testGetEmpty() {
		local.playlists = [:]
		let response = expectation(description: "received")
		provider.object(for: "playlist1", queue: .global()) { (result) in
			if result == nil {
				response.fulfill()
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
    }

	func testGetOne() {
		var playlist = PlaylistProxy()
		playlist.name = "example"
		playlist.playlistId = "playlist1"
		local.playlists = [:]
		local.playlists["playlist1"] = playlist
		let response = expectation(description: "received")
		provider.object(for: "playlist1", queue: .global()) { (result) in
			if let result = result {
				XCTAssertEqual(result.name, playlist.name)
				XCTAssertEqual(result.playlistId, playlist.playlistId)
				response.fulfill()
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
	}

	func testGetTwo() {
		local.playlists = [:]
		for k in (1...2) {
			var p = PlaylistProxy()
			p.name = "example\(k)"
			p.playlistId = "playlist\(k)"
			local.playlists[p.playlistId] = p
		}
		let response = expectation(description: "received")
		provider.objects(for: ["playlist1", "playlist2"], queue: .global()) { (results) in
			XCTAssertEqual(results.count, 2)
			response.fulfill()
		}
		waitForExpectations(timeout: 1.0, handler: nil)
	}

	func testUpdateOne() {
		local.playlists = [:]
		var p = PlaylistProxy()
		p.name = "example1"
		p.playlistId = "playlist1"
		local.playlists[p.playlistId] = p
		p.name = "example2"
		let response = expectation(description: "received")
		provider.update(p, queue: .global()) { (result) in
			XCTAssertEqual(result.name, p.name)
			response.fulfill()
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		if let confirm = local.playlists["playlist1"] {
			XCTAssertEqual(confirm.playlistId, p.playlistId)
			XCTAssertEqual(confirm.name, p.name)
		}
		else {
			XCTFail("not found")
		}
	}

	func testUpdateTwo() {
		local.playlists = [:]
		for k in (1...2) {
			var p = PlaylistProxy()
			p.name = "example\(k)"
			p.playlistId = "playlist\(k)"
			local.playlists[p.playlistId] = p
		}
		let response = expectation(description: "received")
		var updatedList = [PlaylistProxy](local.playlists.values)
		updatedList[0].name = "example6"
		updatedList[1].name = "example7"
		provider.update(updatedList, queue: .global()) { (results) in
			XCTAssertEqual(results.count, 2)
			if let first = results.first {
				XCTAssertEqual(first.name, updatedList[0].name)
			}
			if let last = results.last {
				XCTAssertEqual(last.name, updatedList[1].name)
			}
			response.fulfill()
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		for k in (1...2) {
			if let confirm = local.playlists["playlist\(k)"] {
				XCTAssertEqual(confirm.playlistId, "playlist\(k)")
				XCTAssertEqual(confirm.name, "example\(k+5)")
			}
			else {
				XCTFail("not found")
			}
		}
	}

	func testDestroy() {
		var playlist = PlaylistProxy()
		playlist.name = "example"
		playlist.playlistId = "playlist1"
		local.playlists = [:]
		local.playlists["playlist1"] = playlist
		let response = expectation(description: "received")
		provider.destroy(playlist, queue: .global()) { (result) in
			XCTAssertEqual(result.name, playlist.name)
			XCTAssertEqual(result.playlistId, playlist.playlistId)
			response.fulfill()
		}
		waitForExpectations(timeout: 1.0, handler: nil)

		XCTAssertEqual(local.playlists.count, 0)
	}

}
