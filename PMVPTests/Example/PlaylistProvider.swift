//
//  PlaylistProvider.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift
@testable import PMVP

class PlaylistProvider: Provider<String, PlaylistProxy, Playlist, PlaylistRemoteObject, PlaylistLocalStorage, PlaylistRemoteStorage> {

	override func createSubject() -> BehaviorSubject<PlaylistProxy?> {
		return BehaviorSubject<PlaylistProxy?>(value: nil)
	}

	override func createCollectionSubject() -> BehaviorSubject<[PlaylistProxy]> {
		return BehaviorSubject<[PlaylistProxy]>(value: [])
	}

	override func createKeyListSubject() -> BehaviorSubject<[String]> {
		return BehaviorSubject<[String]>(value: [])
	}

}
