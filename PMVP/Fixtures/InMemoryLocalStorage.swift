//
//  InMemoryLocalStorage.swift
//  PMVP
//
//  Thread-safe in-memory store for local objects.
//
//  Created by Aubrey Goodman on 5/19/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

open class InMemoryLocalStorage<K: Hashable, L: LocalObject, P: Proxy<K>, E: Error>: LocalStorage<K, L, P, E> {

	private var localObjectMap: [K: L] = [:]

	internal let accessQueue: DispatchQueue

	public init(converter: Converter<K, L, P>, queue: DispatchQueue) {
		self.accessQueue = queue
		super.init(converter: converter)
	}

	override open func objects(for keys: [K], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		accessQueue.async { [weak self] in
			guard let strongSelf = self else {
				queue.async { callback(.failure(nil)) }
				return
			}
			var results: [P] = []
			results.reserveCapacity(keys.count)
			for key in keys {
				if let object = strongSelf.localObjectMap[key] {
					let proxy: P = strongSelf.converter.toProxy(object)
					results.append(proxy)
				}
			}
			queue.async { callback(.success(results)) }
		}
	}

	override open func object(for key: K, queue: DispatchQueue, callback: @escaping (Result<P?, E>) -> Void) {
		let converter = self.converter
		accessQueue.async { [weak self] in
			if let localObject: L = self?.localObjectMap[key] {
				let proxy: P = converter.toProxy(localObject)
				queue.async { callback(.success(proxy)) }
			}
			else {
				queue.async { callback(.success(nil)) }
			}
		}
	}

	override open func allObjects(queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		accessQueue.async { [weak self] in
			guard let strongSelf = self else {
				queue.async { callback(.failure(nil)) }
				return
			}
			let localObjects: [L] = [L](strongSelf.localObjectMap.values)
			let proxies: [P] = localObjects.map({ strongSelf.converter.toProxy($0) })
			queue.async { callback(.success(proxies)) }
		}
	}

	override open func update(_ proxies: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		accessQueue.async { [weak self] in
			guard let strongSelf = self else {
				queue.async { callback(.failure(nil)) }
				return
			}
			var results: [P] = []
			results.reserveCapacity(proxies.count)
			for proxy in proxies {
				let localObject: L = strongSelf.converter.fromProxy(proxy)
				strongSelf.localObjectMap[proxy.key] = localObject
			}
			queue.async { callback(.success(proxies)) }
		}
	}

	override open func update(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		let converter = self.converter
		accessQueue.async { [weak self] in
			let localObject: L = converter.fromProxy(object)
			self?.localObjectMap[object.key] = localObject
			queue.async { callback(.success(object)) }
		}
	}

	override open func destroy(_ proxies: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		accessQueue.async { [weak self] in
			for proxy in proxies {
				self?.localObjectMap.removeValue(forKey: proxy.key)
			}
			queue.async { callback(.success(proxies)) }
		}
	}

	override open func destroy(_ proxy: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		accessQueue.async { [weak self] in
			self?.localObjectMap.removeValue(forKey: proxy.key)
			queue.async { callback(.success(proxy)) }
		}
	}

}
