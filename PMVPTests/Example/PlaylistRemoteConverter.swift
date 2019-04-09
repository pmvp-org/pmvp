//
//  PlaylistRemoteConverter.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistRemoteConverter: Converter<PlaylistRemoteObject, PlaylistProxy> {

	override func toProxy(_ object: PlaylistRemoteObject) -> PlaylistProxy {
		var proxy = PlaylistProxy()
		proxy.playlistId = object.playlistId
		proxy.name = object.name
		return proxy
	}

	override func fromProxy(_ proxy: PlaylistProxy) -> PlaylistRemoteObject {
		var remote = PlaylistRemoteObject()
		remote.playlistId = proxy.playlistId
		remote.name = proxy.name
		return remote
	}

}
