//
//  PlaylistAccessor.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 5/1/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import CoreData
@testable import PMVP

class PlaylistAccessor: CoreDataAccessor<String, CoreDataPlaylist, PlaylistProxy, PlaylistError> {

	override func insert(_ object: PlaylistProxy, in context: NSManagedObjectContext) {
		guard let newObject: CoreDataPlaylist = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? CoreDataPlaylist else { return }
		newObject.key = object.key
		newObject.value = object.name
	}

	override func update(_ object: CoreDataPlaylist, with proxy: PlaylistProxy) {
		if object.key != proxy.key {
			object.key = proxy.key
		}
		if object.value != proxy.name {
			object.value = proxy.name
		}
	}

}
