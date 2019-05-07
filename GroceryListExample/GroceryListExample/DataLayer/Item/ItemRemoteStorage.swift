//
//  ItemRemoteStorage.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemRemoteStorage: RemoteStorage<String, ItemRemote, ItemProxy, ItemError> {

	override func allObjects(queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {

	}

	override func object(for key: String, queue: DispatchQueue, callback: @escaping (Result<ItemProxy?, ItemError>) -> Void) {

	}

	override func objects(for keys: [String], queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {

	}

	override func update(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (Result<ItemProxy, ItemError>) -> Void) {

	}

	override func update(_ objects: [ItemProxy], queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {

	}

	override func destroy(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (Result<ItemProxy, ItemError>) -> Void) {

	}
	
}
