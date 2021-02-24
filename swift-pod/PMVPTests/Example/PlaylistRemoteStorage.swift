//
//  PlaylistRemoteStorage.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

@testable import PMVP

class PlaylistRemoteStorage: RemoteStorage<String, PlaylistRemoteObject, PlaylistProxy, PlaylistError> {

	var didGetAll: Bool = false
	var didGetOne: Bool = false
	var didGetMany: Bool = false
	var didUpdateOne: Bool = false
	var didUpdateMany: Bool = false
	var didDestroy: Bool = false

	private let testQueue = DispatchQueue(label: "test.remote")

	override func allObjects(queue: DispatchQueue, callback: @escaping (Result<[PlaylistProxy], PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didGetAll = true
			queue.async { callback(.success([])) }
		}
	}

	override func object(for key: String, queue: DispatchQueue, callback: @escaping (Result<PlaylistProxy?, PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didGetOne = true
			queue.async { callback(.success(nil)) }
		}
	}

	override func objects(for keys: [String], queue: DispatchQueue, callback: @escaping (Result<[PlaylistProxy], PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didGetMany = true
			queue.async { callback(.success([])) }
		}
	}

	override func update(_ object: PlaylistProxy, queue: DispatchQueue, callback: @escaping (Result<PlaylistProxy, PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didUpdateOne = true
			queue.async { callback(.success(object)) }
		}
	}

	override func update(_ objects: [PlaylistProxy], queue: DispatchQueue, callback: @escaping (Result<[PlaylistProxy], PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didUpdateMany = true
			queue.async { callback(.success(objects)) }
		}
	}

	override func destroy(_ object: PlaylistProxy, queue: DispatchQueue, callback: @escaping (Result<PlaylistProxy, PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didDestroy = true
			queue.async { callback(.success(object)) }
		}
	}

	override func destroy(_ objects: [PlaylistProxy], queue: DispatchQueue, callback: @escaping (Result<[PlaylistProxy], PlaylistError>) -> Void) {
		testQueue.async { [weak self] in
			self?.didDestroy = true
			queue.async { callback(.success(objects)) }
		}
	}

}
