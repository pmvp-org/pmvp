//
//  ItemLocalStorage.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemLocalStorage: LocalStorage<String, ItemLocal, ItemProxy, ItemError> {

	private var items: [String: ItemLocal] = [:]

	override func allObjects(queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {
		let results = items.values.map({ self.converter.toProxy($0) })
		queue.async { callback(.success(results)) }
	}

	override func object(for key: String, queue: DispatchQueue, callback: @escaping (Result<ItemProxy?, ItemError>) -> Void) {
		if let result = items[key] {
			let proxy = converter.toProxy(result)
			queue.async { callback(.success(proxy)) }
		}
		else {
			queue.async { callback(.success(nil)) }
		}
	}

	override func objects(for keys: [String], queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {
		var results: [ItemLocal] = []
		results.reserveCapacity(keys.count)
		for key in keys {
			if let item = items[key] {
				results.append(item)
			}
		}
		let mappedResults = results.map({ self.converter.toProxy($0) })
		queue.async { callback(.success(mappedResults)) }
	}

	override func update(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (Result<ItemProxy, ItemError>) -> Void) {
		items[object.key] = converter.fromProxy(object)
		queue.async { callback(.success(object)) }
	}

	override func update(_ objects: [ItemProxy], queue: DispatchQueue, callback: @escaping (Result<[ItemProxy], ItemError>) -> Void) {
		for obj in objects {
			items[obj.key] = converter.fromProxy(obj)
		}
		queue.async { callback(.success(objects)) }
	}

	override func destroy(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (Result<ItemProxy, ItemError>) -> Void) {
		items.removeValue(forKey: object.key)
		queue.async { callback(.success(object)) }
	}

}
