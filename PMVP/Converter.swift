//
//  Converter.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  SPDX-License-Identifier: MIT
//  Copyright © 2019 Aubrey Goodman.
//

open class Converter<K: Hashable, T: AbstractObject, P: Proxy<K>> {

	public init() {}

	open func insert(using proxy: P) -> T {
		fatalError("unimplemented \(#function)")
	}

	open func update(_ object: T, from proxy: P) {
		fatalError("unimplemented \(#function)")
	}

	open func toProxy(_ object: T) -> P {
		fatalError("unimplemented \(#function)")
	}

}
