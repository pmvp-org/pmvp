//
//  Provider.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  SPDX-License-Identifier: MIT
//  Copyright © 2019 Aubrey Goodman.
//

import RxSwift

open class Provider<K: Hashable, T: Proxy<K>, A: LocalObject, B: RemoteObject, E: Error, L: LocalStorage<K, A, T, E>, R: RemoteStorage<K, B, T, E>> {

	public let localStorage: LocalStorage<K, A, T, E>

	public let remoteStorage: RemoteStorage<K, B, T, E>

	public let storageQueue: DispatchQueue

	public let scheduler: SchedulerType

	private let subjectHolder: KeyedSubjectHolder<K, T>

	private let collectionHolder: CollectionSubjectHolder<T>

	private let keysSubjectHolder: CollectionSubjectHolder<K>

	public init(queueName: String, localStorage: LocalStorage<K, A, T, E>, remoteStorage: RemoteStorage<K, B, T, E>) {
		let queue = DispatchQueue(label: queueName)
		self.storageQueue = queue
		self.scheduler = SerialDispatchQueueScheduler(queue: storageQueue, internalSerialQueueName: queueName)
		self.localStorage = localStorage
		self.remoteStorage = remoteStorage

		let subjectPreloader: (K, BehaviorSubject<T?>) -> Void = { key, subject in
			localStorage.object(for: key, queue: queue, callback: { (result) in
				switch result {
				case .success(let object):
					subject.onNext(object)
				default:
					break
				}
			})
		}
		subjectHolder = KeyedSubjectHolder<K, T>(scheduler: scheduler, preloader: subjectPreloader)

		let keyPreloader: (BehaviorSubject<[K]>) -> Void = { subject in
			localStorage.allObjects(queue: queue, callback: { (result) in
				switch result {
				case .success(let objects):
					subject.onNext(objects.map({ $0.key }))
				default:
					break
				}
			})
		}
		keysSubjectHolder = CollectionSubjectHolder<K>(scheduler: scheduler, preloader: keyPreloader)

		let collectionPreloader: (BehaviorSubject<[T]>) -> Void = { subject in
			localStorage.allObjects(queue: queue, callback: { (result) in
				switch result {
				case .success(let objects):
					subject.onNext(objects)
				default:
					break
				}
			})
		}
		collectionHolder = CollectionSubjectHolder<T>(scheduler: scheduler, preloader: collectionPreloader)
	}

	// MARK: - Required Methods

	// MARKL - Optional Methods

	public func shouldNotifyAllOnUpdate() -> Bool {
		return true
	}

	open func didErrorOnNotify(_ error: Error?) {
	}

	open func notify(_ object: T?) {
		guard let key = object?.key else { return }
		let observable = subjectHolder.subject(for: key)
		if let subject = observable as? BehaviorSubject<T?> {
			subject.onNext(object)
		}

		if shouldNotifyAllOnUpdate() {
			localStorage.allObjects(queue: storageQueue) { [weak self] (result) in
				switch result {
				case .success(let objects):
					self?.collectionHolder.notify(objects)
				case .failure(let error):
					self?.didErrorOnNotify(error)
				}
			}
		}
	}

	// MARK: - Basic ORM

	public final func object(for key: K, queue: DispatchQueue, callback: @escaping (Result<T?, E>) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.object(for: key, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func objects(for keys: [K], queue: DispatchQueue, callback: @escaping (Result<[T], E>) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.objects(for: keys, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func objects(queue: DispatchQueue, callback: @escaping (Result<[T], E>) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		storageQueue.async { local.allObjects(queue: workerQueue, callback: callback) }
	}

	public final func update(_ object: T, queue: DispatchQueue, callback: @escaping (Result<T, E>) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.update(object, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func update(_ objects: [T], queue: DispatchQueue, callback: @escaping (Result<[T], E>) -> Void) {
		let local = self.localStorage
		let workerQueue = self.storageQueue
		let wrapperCallback = buildWrapper(using: queue, for: callback)
		storageQueue.async { local.update(objects, queue: workerQueue, callback: wrapperCallback) }
	}

	public final func destroy(_ object: T, queue: DispatchQueue, callback: @escaping (Result<T, E>) -> Void) {
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

	typealias OptionalInstanceCallback = (Result<T?, E>) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping OptionalInstanceCallback) -> OptionalInstanceCallback {
		return { [weak self] (result: Result<T?, E>) in
			switch result {
			case .success(let object):
				queue.async { callback(.success(object)) }
				self?.notify(object)
			case .failure(let error):
				queue.async { callback(.failure(error)) }
			}
		}
	}

	typealias InstanceCallback = (Result<T, E>) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping InstanceCallback) -> InstanceCallback {
		return { [weak self] (result: Result<T, E>) in
			switch result {
			case .success(let object):
				queue.async { callback(.success(object)) }
				self?.notify(object)
			case .failure(let error):
				queue.async { callback(.failure(error)) }
			}
		}
	}

	typealias ArrayCallback = (Result<[T], E>) -> Void
	private func buildWrapper(using queue: DispatchQueue, for callback: @escaping ArrayCallback) -> ArrayCallback {
		return { [weak self] (results: Result<[T], E>) in
			switch results {
			case .success(let objects):
				queue.async { callback(.success(objects)) }
				for observer in objects {
					self?.notify(observer)
				}
			case .failure(let error):
				queue.async { callback(.failure(error)) }
			}
		}
	}

}
