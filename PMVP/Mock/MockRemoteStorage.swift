//
//  MockRemoteStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/22/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

open class MockRemoteStorage<K: Hashable, T: Proxy<K>, R: RemoteObject>: RemoteStorage<K, R, T> {

	public var objectMap: [K: T] = [:]
	public var didUpdateObject: [K: Bool] = [:]
	public var didDestroyObject: [K: Bool] = [:]

	open override func object(for key: K, queue: DispatchQueue, callback: @escaping (T?) -> Void) {
		let result = objectMap[key]
		queue.async { callback(result) }
	}

	open override func objects(for keys: [K], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		var results: [T] = []
		results.reserveCapacity(keys.count)
		for key in keys {
			if let result = objectMap[key] {
				results.append(result)
			}
		}
		queue.async { callback(results) }
	}

	open override func update(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let key: K = object.key
		didUpdateObject[key] = true
		objectMap[key] = object
		queue.async { callback(object) }
	}

	open override func update(_ objects: [T], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		for obj in objects {
			let key: K = obj.key
			didUpdateObject[key] = true
			objectMap[key] = obj
		}
		queue.async { callback(objects) }
	}

	open override func destroy(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let key: K = object.key
		didDestroyObject[key] = true
		objectMap.removeValue(forKey: key)
		queue.async { callback(object) }
	}

	open override func allObjects(queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		let results: [T] = [T](objectMap.values)
		queue.async { callback(results) }
	}

}

