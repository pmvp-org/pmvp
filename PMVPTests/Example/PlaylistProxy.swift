//
//  PlaylistProxy.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistProxy: Proxy<String> {

	var name: String = ""

	init(id: String, name: String) {
		self.name = name
		super.init(key: id)
	}

}
