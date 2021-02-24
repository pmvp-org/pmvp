//
//  PagedStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/29/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

public enum PagedStorageOrder {
	case ascending
	case descending
}

public protocol PagedStorage {
	associatedtype K: Comparable & Hashable
	associatedtype T: Proxy<K>
	associatedtype E: Error

	func batchObjects(startingAt key: K,
					  limit: Int,
					  order: PagedStorageOrder,
					  queue: DispatchQueue,
					  callback: @escaping (Result<[T], E>) -> Void)
}
