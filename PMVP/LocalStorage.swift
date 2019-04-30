//
//  LocalStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

open class LocalStorage<K, L: LocalObject, P: Proxy<K>, E: Error>: Storage {

	public let converter: Converter<K, L, P>

	public init(converter: Converter<K, L, P>) {
		self.converter = converter
	}

	open func object(for key: K, queue: DispatchQueue, callback: @escaping (Result<P?, E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func objects(for keys: [K], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func allObjects(queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func update(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func update(_ objects: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func destroy(_ object: P, queue: DispatchQueue, callback: @escaping (Result<P, E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	open func destroy(_ objects: [P], queue: DispatchQueue, callback: @escaping (Result<[P], E>) -> Void) {
		fatalError("unimplemented \(#function)")
	}

}
