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

	open func fromProxy(_ proxy: P) -> T {
		fatalError("unimplemented \(#function)")
	}

	open func toProxy(_ object: T) -> P {
		fatalError("unimplemented \(#function)")
	}

}
