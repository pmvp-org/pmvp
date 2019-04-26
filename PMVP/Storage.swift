//
//  Storage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

public protocol Storage {
	associatedtype K: Hashable
	associatedtype P: Proxy<K>

	func object(for key: K, queue: DispatchQueue, callback: @escaping (P?) -> Void)

	func objects(for keys: [K], queue: DispatchQueue, callback: @escaping ([P]) -> Void)

	func allObjects(queue: DispatchQueue, callback: @escaping ([P]) -> Void)

	func update(_ object: P, queue: DispatchQueue, callback: @escaping (P) -> Void)

	func update(_ objects: [P], queue: DispatchQueue, callback: @escaping ([P]) -> Void)

	func destroy(_ object: P, queue: DispatchQueue, callback: @escaping (P) -> Void)

}
