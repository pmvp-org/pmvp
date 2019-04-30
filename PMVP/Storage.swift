//
//  Storage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

public enum Result<T, E: Error> {
	case success(T)
	case failure(E?)
}

public protocol Storage {
	associatedtype K: Hashable
	associatedtype P: Proxy<K>
	associatedtype E: Error

	func object(for key: K, queue: DispatchQueue, callback: @escaping (Result<P?, E>) -> Void)

	func objects(for keys: [K], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void)

	func allObjects(queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void)

	func update(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void)

	func update(_ objects: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void)

	func destroy(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void)

	func destroy(_ objects: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void)

}
