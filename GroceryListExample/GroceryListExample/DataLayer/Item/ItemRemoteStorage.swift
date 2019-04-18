//
//  ItemRemoteStorage.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemRemoteStorage: RemoteStorage<String, ItemRemote, ItemProxy> {

	override func allObjects(queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {

	}

	override func object(for key: String, queue: DispatchQueue, callback: @escaping (ItemProxy?) -> Void) {

	}

	override func objects(for keys: [String], queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {

	}

	override func update(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (ItemProxy) -> Void) {

	}

	override func update(_ objects: [ItemProxy], queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {

	}

	override func destroy(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (ItemProxy) -> Void) {

	}
	
}
