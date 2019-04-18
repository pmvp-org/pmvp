//
//  Provider.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

open class Provider<K: Hashable, T: Proxy, A: LocalObject, B: RemoteObject, L: LocalStorage<K, A, T>, R: RemoteStorage<K, B, T>> {

	private let localStorage: LocalStorage<K, A, T>

	private let remoteStorage: RemoteStorage<K, B, T>

	private let storageQueue: DispatchQueue

	private let scheduler: SchedulerType

	private var keysSubject: BehaviorSubject<[K]>!

	private var collectionSubject: BehaviorSubject<[T]>!

	private var subjectMap: [K: BehaviorSubject<T?>] = [:]

	public init(queueName: String, localStorage: LocalStorage<K, A, T>, remoteStorage: RemoteStorage<K, B, T>) {
		self.storageQueue = DispatchQueue(label: queueName)
		self.scheduler = SerialDispatchQueueScheduler(queue: storageQueue, internalSerialQueueName: queueName)
		self.localStorage = localStorage
		self.remoteStorage = remoteStorage
		keysSubject = createKeyListSubject()
		collectionSubject = createCollectionSubject()
	}

	// MARK: - Required Methods

	open func createSubject() -> BehaviorSubject<T?> {
		fatalError("unimplemented \(#function)")
	}

	open func createKeyListSubject() -> BehaviorSubject<[K]> {
		fatalError("unimplemented \(#function)")
	}

	open func createCollectionSubject() -> BehaviorSubject<[T]> {
		fatalError("unimplemented \(#function)")
	}

	open func key(for object: T?) -> K? {
		fatalError("unimplemented \(#function)")
	}

	// MARKL - Optional Methods

	public func shouldNotifyAllOnUpdate() -> Bool {
		return true
	}

	// MARK: - Basic ORM

	public final func object(for key: K, queue: DispatchQueue, callback: @escaping (T?) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.object(for: key, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func objects(for keys: [K], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.objects(for: keys, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func update(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.update(object, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func update(_ objects: [T], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.update(objects, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func destroy(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperQueue = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.destroy(object, queue: workerQueue, callback: wrapperQueue) }
	}

	// MARK: - Rx Observable Methods

	public final func keys() -> Observable<[K]> {
		var result: Observable<[K]>!
		storageQueue.sync { [weak self] in
			guard let strongSelf = self else {
				fatalError("impossible")
			}
			result = strongSelf.keysSubject
		}
		return result
	}

	public final func objects() -> Observable<[T]> {
		var result: Observable<[T]>!
		storageQueue.sync { [weak self] in
			guard let strongSelf = self else {
				fatalError("impossible")
			}
			result = strongSelf.collectionSubject
		}
		return result
	}

	public final func object(for key: K) -> Observable<T?> {
		var result: Observable<T?>!
		storageQueue.sync { [weak self] in
			guard let strongSelf = self else {
				fatalError("impossible")
			}
			result = strongSelf.findOrCreateSubject(for: key)
		}
		return result
	}

	// MARK: - Private Helper Methods

	private func findOrCreateSubject(for key: K) -> BehaviorSubject<T?> {
		if let existingSubject: BehaviorSubject<T?> = subjectMap[key] {
			return existingSubject
		}
		else {
			let newSubject: BehaviorSubject<T?> = createSubject()
			subjectMap[key] = newSubject
			_ = newSubject
				.observeOn(scheduler)
				.do(onDispose: { [weak self] in self?.clearUnusedSubject(for: key) })
			return newSubject
		}
	}

	private func clearUnusedSubject(for key: K) {
		if let subject: BehaviorSubject<T?> = subjectMap[key], !subject.hasObservers {
			subjectMap.removeValue(forKey: key)
		}
	}

	private func notify(_ object: T?) {
		guard let key = self.key(for: object) else { return }
		if let subject = subjectMap[key] {
			subject.onNext(object)
		}
		if shouldNotifyAllOnUpdate() {
			localStorage.allObjects(queue: storageQueue) { [weak self] (results) in
				self?.collectionSubject.onNext(results)
			}
		}
	}

	typealias OptionalInstanceCallback = (T?) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping OptionalInstanceCallback) -> OptionalInstanceCallback {
		return { [weak self] (result: T?) in
			queue.async { callback(result) }
			self?.notify(result)
		}
	}

	typealias InstanceCallback = (T) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping InstanceCallback) -> InstanceCallback {
		return { [weak self] (result: T) in
			queue.async { callback(result) }
			self?.notify(result)
		}
	}

	typealias ArrayCallback = ([T]) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping ArrayCallback) -> ArrayCallback {
		return { [weak self] (results: [T]) in
			queue.async { callback(results) }
			for observer in results {
				self?.notify(observer)
			}
		}
	}

}
