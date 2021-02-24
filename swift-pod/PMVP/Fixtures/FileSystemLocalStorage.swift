//
//  FileSystemLocalStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 5/19/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

class FileSystemLocalStorage<K: Hashable, L: LocalObject, P: Proxy<K>, E: Error>: InMemoryLocalStorage<K, L, P, E> {

	private let filename: String

	init(converter: Converter<K, L, P>, queue: DispatchQueue, filename: String) {
		self.filename = filename
		super.init(converter: converter, queue: queue)
		loadFromFile()
	}

	override func update(_ proxy: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		let wrapperCallback: (Result<P, E>) -> Void = { [weak self] result in
			queue.async { callback(result) }
			self?.saveToFile()
		}
		super.update(proxy, queue: accessQueue, callback: wrapperCallback)
	}

	override func update(_ proxies: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		let wrapperCallback: (Result<[P], E>) -> Void = { [weak self] result in
			queue.async { callback(result) }
			self?.saveToFile()
		}
		super.update(proxies, queue: accessQueue, callback: wrapperCallback)
	}

	override func destroy(_ proxy: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		let wrapperCallback: (Result<P, E>) -> Void = { [weak self] result in
			queue.async { callback(result) }
			self?.saveToFile()
		}
		super.destroy(proxy, queue: accessQueue, callback: wrapperCallback)
	}

	override func destroy(_ proxies: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		let wrapperCallback: (Result<[P], E>) -> Void = { [weak self] result in
			queue.async { callback(result) }
			self?.saveToFile()
		}
		super.destroy(proxies, queue: accessQueue, callback: wrapperCallback)
	}

	// MARK: Required Overrides

	open func loadFromFile() {
	}

	open func saveToFile() {
	}

}
