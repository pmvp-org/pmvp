//
//  ItemLocalStorage.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemLocalStorage: LocalStorage<String, ItemLocal, ItemProxy> {

	private var items: [String: ItemLocal] = [:]

	override func allObjects(queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {
		let results = items.values.map({ self.converter.toProxy($0) })
		queue.async { callback(results) }
	}

	override func object(for key: String, queue: DispatchQueue, callback: @escaping (ItemProxy?) -> Void) {
		if let result = items[key] {
			queue.async { callback(self.converter.toProxy(result)) }
		}
		else {
			queue.async { callback(nil) }
		}
	}

	override func objects(for keys: [String], queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {
		var results: [ItemLocal] = []
		results.reserveCapacity(keys.count)
		for key in keys {
			if let item = items[key] {
				results.append(item)
			}
		}
		let mappedResults = results.map({ self.converter.toProxy($0) })
		queue.async { callback(mappedResults) }
	}

	override func update(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (ItemProxy) -> Void) {
		items[object.key] = converter.fromProxy(object)
		queue.async { callback(object) }
	}

	override func update(_ objects: [ItemProxy], queue: DispatchQueue, callback: @escaping ([ItemProxy]) -> Void) {
		for obj in objects {
			items[obj.key] = converter.fromProxy(obj)
		}
		queue.async { callback(objects) }
	}

	override func destroy(_ object: ItemProxy, queue: DispatchQueue, callback: @escaping (ItemProxy) -> Void) {
		items.removeValue(forKey: object.key)
		queue.async { callback(object) }
	}

}
