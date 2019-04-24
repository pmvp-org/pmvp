//
//  Provider.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

open class Provider<K: Hashable, T: Proxy<K>, A: LocalObject, B: RemoteObject, L: LocalStorage<K, A, T>, R: RemoteStorage<K, B, T>> {

	public let localStorage: LocalStorage<K, A, T>

	public let remoteStorage: RemoteStorage<K, B, T>

	public let storageQueue: DispatchQueue

	public let scheduler: SchedulerType

	private let subjectHolder: KeyedSubjectHolder<K, T>

	private let collectionHolder: CollectionSubjectHolder<T>

	private let keysSubjectHolder: CollectionSubjectHolder<K>

	public init(queueName: String, localStorage: LocalStorage<K, A, T>, remoteStorage: RemoteStorage<K, B, T>) {
		let queue = DispatchQueue(label: queueName)
		self.storageQueue = queue
		self.scheduler = SerialDispatchQueueScheduler(queue: storageQueue, internalSerialQueueName: queueName)
		self.localStorage = localStorage
		self.remoteStorage = remoteStorage

		let subjectPreloader: (K, BehaviorSubject<T?>) -> Void = { key, subject in
			localStorage.object(for: key, queue: queue, callback: { (result) in subject.onNext(result) })
		}
		subjectHolder = KeyedSubjectHolder<K, T>(scheduler: scheduler, preloader: subjectPreloader)

		let keyPreloader: (BehaviorSubject<[K]>) -> Void = { subject in
			localStorage.allObjects(queue: queue, callback: { (results) in subject.onNext(results.map({ $0.key })) })
		}
		keysSubjectHolder = CollectionSubjectHolder<K>(scheduler: scheduler, preloader: keyPreloader)

		let collectionPreloader: (BehaviorSubject<[T]>) -> Void = { subject in
			localStorage.allObjects(queue: queue, callback: { (results) in subject.onNext(results) })
		}
		collectionHolder = CollectionSubjectHolder<T>(scheduler: scheduler, preloader: collectionPreloader)
	}

	// MARK: - Required Methods

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
			result = strongSelf.keysSubjectHolder.subject()
		}
		return result
	}

	public final func objects() -> Observable<[T]> {
		var result: Observable<[T]>!
		storageQueue.sync { [weak self] in
			guard let strongSelf = self else {
				fatalError("impossible")
			}
			result = strongSelf.collectionHolder.subject()
		}
		return result
	}

	public final func object(for key: K) -> Observable<T?> {
		var result: Observable<T?>!
		storageQueue.sync { [weak self] in
			guard let strongSelf = self else {
				fatalError("impossible")
			}
			result = strongSelf.subjectHolder.subject(for: key).distinctUntilChanged()
		}
		return result
	}

	// MARK: - Private Helper Methods

	private func notify(_ object: T?) {
		guard let key = object?.key else { return }
		let observable = subjectHolder.subject(for: key)
		if let subject = observable as? BehaviorSubject<T?> {
			subject.onNext(object)
		}

		if shouldNotifyAllOnUpdate() {
			localStorage.allObjects(queue: storageQueue) { [weak self] (results) in
				self?.collectionHolder.notify(results)
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
