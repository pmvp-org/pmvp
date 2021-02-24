//
//  ItemProxy.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemProxy: Proxy<String> {

	var value: String

	init(key: String, value: String) {
		self.value = value
		super.init(key: key)
	}
	
}
