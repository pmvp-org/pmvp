//
//  LocalPagedStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/29/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

open class LocalPagedStorage<K: Comparable, T: Proxy<K>, E: Error, L: LocalObject>: PagedStorage {

	public let converter: Converter<K, L, T>

	init(converter: Converter<K, L, T>) {
		self.converter = converter
	}

	open func batchObjects(startingAt key: K, limit: Int, order: PagedStorageOrder, queue: DispatchQueue, callback: @escaping (Result<[T], E>) -> Void) {
		fatalError()
	}

}
