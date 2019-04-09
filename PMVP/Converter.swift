//
//  Converter.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

class Converter<T: AbstractObject, P: Proxy> {

	func fromProxy(_ proxy: P) -> T {
		fatalError("unimplemented \(#function)")
	}

	func toProxy(_ object: T) -> P {
		fatalError("unimplemented \(#function)")
	}

}
