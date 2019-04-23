//
//  PlaylistRemoteConverter.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistRemoteConverter: Converter<String, PlaylistRemoteObject, PlaylistProxy> {

	override func toProxy(_ object: PlaylistRemoteObject) -> PlaylistProxy {
		return PlaylistProxy(id: object.playlistId, name: object.name)
	}

	override func fromProxy(_ proxy: PlaylistProxy) -> PlaylistRemoteObject {
		let remote = PlaylistRemoteObject()
		remote.playlistId = proxy.key
		remote.name = proxy.name
		return remote
	}

}
