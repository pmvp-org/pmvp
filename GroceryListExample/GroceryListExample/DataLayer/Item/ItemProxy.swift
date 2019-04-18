//
//  ItemProxy.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemProxy: Proxy, CustomStringConvertible {

	var key: String
	var value: String

	init(key: String, value: String) {
		self.key = key
		self.value = value
	}

	static func ==(_ a: ItemProxy, _ b: ItemProxy) -> Bool {
		let key = a.key == b.key
		let value = a.value == b.value
		return key && value
	}

	var description: String {
		return "\(key) => \(value)"
	}

}
