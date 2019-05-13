//
//  CoreDataLocalStorage.swift
//  PMVPCoreData
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import CoreData

open class CoreDataLocalStorage<K: Hashable & Comparable, L: NSManagedObject & LocalObject, P: Proxy<K>, E: Error>: LocalStorage<K, L, P, E> {

	public let accessor: CoreDataAccessor<K, L, P, E>

	private let keyName: String

	private let storageQueue: DispatchQueue

	public init(queue: DispatchQueue? = nil,
				entityName: String,
				keyName: String,
				converter: Converter<K, L, P>,
				contextFactory: @escaping () -> NSManagedObjectContext) {
		if let queue = queue {
			self.storageQueue = queue
		}
		else {
			self.storageQueue = DispatchQueue(label: "\(entityName).queue")
		}
		self.keyName = keyName
		self.accessor = CoreDataAccessor<K, L, P, E>(contextFactory: contextFactory,
													 entityName: entityName,
													 keyName: keyName,
													 converter: converter)
		super.init(converter: converter)
	}

	typealias ProxyInstanceResult = (Result<P, E>) -> Void
	typealias ProxyOptionalInstanceResult = (Result<P?, E>) -> Void
	typealias ProxyCollectionResult = (Result<[P], E>) -> Void
	typealias CoreDataCollectionResult = (CoreDataResult<[P], E>) -> Void
	override open func object(for key: K, queue: DispatchQueue, callback: @escaping (Result<P?, E>) -> Void) {
		let predicate = NSPredicate(format: "\(keyName) = %@", key as! CVarArg)
		let wrapperCallback: CoreDataCollectionResult = buildOptionalInstanceTransform(for: key, converter: converter, callback: callback)
		accessor.objects(predicate: predicate,
						 sortDescriptors: [],
						 limit: 1,
						 queue: storageQueue,
						 callback: wrapperCallback)
	}

	typealias ArrayResult = (Result<[P], E>) -> Void
	override open func objects(for keys: [K], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		let predicate = NSPredicate(format: "\(keyName) in %@", keys as CVarArg)
		let wrapperCallback: CoreDataCollectionResult = buildCollectionTransform(callback: callback)
		accessor.objects(predicate: predicate, sortDescriptors: [], limit: keys.count, queue: storageQueue, callback: wrapperCallback)
	}

	override open func allObjects(queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		let wrapperCallback: CoreDataCollectionResult = buildCollectionTransform(callback: callback)
		accessor.objects(queue: storageQueue, callback: wrapperCallback)
	}

	override open func update(_ proxy: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		let collectionInstanceTransform: (Result<[P], E>) -> Void = { collectionResult in
			switch collectionResult {
			case .success(let objects):
				if let first = objects.first {
					callback(Result.success(first))
				}
				else {
					callback(Result.failure(nil))
				}
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
		update([proxy], queue: queue, callback: collectionInstanceTransform)
	}

	override open func update(_ proxies: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		var proxyMap: [K: P] = [:]
		proxyMap.reserveCapacity(proxies.count)
		for proxy in proxies {
			proxyMap[proxy.key] = proxy
		}

		let wrapperCallback: CoreDataCollectionResult = buildCollectionTransform(callback: callback)
		accessor.upsert(proxyMap, queue: queue, callback: wrapperCallback)
	}

	override open func destroy(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		let keys: [K] = [object.key]
		let wrapperCallback: (CoreDataResult<[K], E>) -> Void = { coreDataResult in
			switch coreDataResult {
			case .success(_):
				callback(Result.success(object))
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
		accessor.destroyObjects(for: keys, queue: queue, callback: wrapperCallback)
	}

	override open func destroy(_ objects: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		let keys: [K] = objects.map({ $0.key })
		let wrapperCallback: (CoreDataResult<[K], E>) -> Void = { coreDataResult in
			switch coreDataResult {
			case .success(_):
				callback(Result.success(objects))
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
		accessor.destroyObjects(for: keys, queue: queue, callback: wrapperCallback)
	}

	private func buildOptionalInstanceTransform(for key: K,
										converter: Converter<K, L, P>,
										callback: @escaping ProxyOptionalInstanceResult) -> CoreDataCollectionResult {
		return { coreDataResult in
			switch coreDataResult {
			case .success(let objects):
				if let first = objects.first {
					callback(Result.success(first))
				}
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
	}
	private func buildInstanceTransform(for key: K,
										callback: @escaping ProxyInstanceResult) -> CoreDataCollectionResult {
		return { coreDataResult in
			switch coreDataResult {
			case .success(let objects):
				if let first = objects.first {
					callback(Result.success(first))
				}
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
	}

	private func buildCollectionTransform(callback: @escaping ProxyCollectionResult) -> CoreDataCollectionResult {
		return { coreDataResult in
			switch coreDataResult {
			case .success(let objects):
				callback(Result.success(objects))
			case .failure(let error):
				callback(Result.failure(error))
			}
		}
	}
}
