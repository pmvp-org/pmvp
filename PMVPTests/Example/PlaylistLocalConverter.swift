//
//  PlaylistLocalConverter.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistLocalConverter: Converter<Playlist, PlaylistProxy> {

	override func toProxy(_ object: Playlist) -> PlaylistProxy {
		var proxy = PlaylistProxy()
		proxy.playlistId = object.playlistId
		proxy.name = object.name
		return proxy
	}

	override func fromProxy(_ proxy: PlaylistProxy) -> Playlist {
		var local = Playlist()
		local.playlistId = proxy.playlistId
		local.name = proxy.name
		return local
	}

}
