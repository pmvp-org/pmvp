//
//  Provider.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

class Provider<K, T: Proxy, A: LocalObject, B: RemoteObject, L: LocalStorage<K, A, T>, R: RemoteStorage<K, B, T>> {

	private let localStorage: LocalStorage<K, A, T>

	private let remoteStorage: RemoteStorage<K, B, T>

	private let storageQueue: DispatchQueue

	init(queueName: String, localStorage: LocalStorage<K, A, T>, remoteStorage: RemoteStorage<K, B, T>) {
		self.storageQueue = DispatchQueue(label: queueName)
		self.localStorage = localStorage
		self.remoteStorage = remoteStorage
	}

	public final func object(for key: K, queue: DispatchQueue, callback: @escaping (T?) -> Void) {
		let local = self.localStorage
		storageQueue.async { local.object(for: key, queue: queue, callback: callback) }
	}

	public final func objects(for keys: [K], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		let local = self.localStorage
		storageQueue.async { local.objects(for: keys, queue: queue, callback: callback) }
	}

	public final func update(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let local = self.localStorage
		storageQueue.async { local.update(object, queue: queue, callback: callback) }
	}

	public final func update(_ objects: [T], queue: DispatchQueue, callback: @escaping ([T]) -> Void) {
		let local = self.localStorage
		storageQueue.async { local.update(objects, queue: queue, callback: callback) }
	}

	public final func destroy(_ object: T, queue: DispatchQueue, callback: @escaping (T) -> Void) {
		let local = self.localStorage
		storageQueue.async { local.destroy(object, queue: queue, callback: callback) }
	}

}
