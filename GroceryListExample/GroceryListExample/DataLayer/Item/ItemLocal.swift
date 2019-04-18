//
//  ItemLocal.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemLocal: LocalObject {

	var key: String
	var value: String

	init(key: String, value: String) {
		self.key = key
		self.value = value
	}

}
