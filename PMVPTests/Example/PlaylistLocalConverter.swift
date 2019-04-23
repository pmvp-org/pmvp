//
//  PlaylistLocalConverter.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistLocalConverter: Converter<String, Playlist, PlaylistProxy> {

	override func toProxy(_ object: Playlist) -> PlaylistProxy {
		return PlaylistProxy(id: object.playlistId, name: object.name)
	}

	override func fromProxy(_ proxy: PlaylistProxy) -> Playlist {
		var local = Playlist()
		local.playlistId = proxy.key
		local.name = proxy.name
		return local
	}

}
