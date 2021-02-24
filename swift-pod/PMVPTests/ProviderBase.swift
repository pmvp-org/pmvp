//
//  ProviderBase.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/9/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest

class ProviderBase: XCTestCase {

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

}
