//
//  LocalStorage.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

class LocalStorage<K, L: LocalObject, P: Proxy>: Storage {

	let converter: Converter<L, P>

	init(converter: Converter<L, P>) {
		self.converter = converter
	}

	func object(for key: K, queue: DispatchQueue, callback: @escaping (P?) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	func objects(for keys: [K], queue: DispatchQueue, callback: @escaping ([P]) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	func allObjects(queue: DispatchQueue, callback: @escaping ([P]) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	func update(_ object: P, queue: DispatchQueue, callback: @escaping (P) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	func update(_ objects: [P], queue: DispatchQueue, callback: @escaping ([P]) -> Void) {
		fatalError("unimplemented \(#function)")
	}

	func destroy(_ object: P, queue: DispatchQueue, callback: @escaping (P) -> Void) {
		fatalError("unimplemented \(#function)")
	}

}
