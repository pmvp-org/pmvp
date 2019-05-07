//
//  ItemKeyFactory.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 5/5/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import Foundation

protocol IKeyFactory {
	associatedtype K: Hashable
	func generate() -> K
}

class KeyFactory<K: Hashable>: IKeyFactory {
	func generate() -> K {
		fatalError("unimplemented \(#function)")
	}
}

class ItemKeyFactory: KeyFactory<String> {

	private var nextId: Int

	private var nextKey: String!

	init(nextId: Int = 1) {
		self.nextId = nextId
		super.init()
		updateNextKey()
	}

	override func generate() -> String {
		return nextKey
	}

	func claim(_ value: String) -> Bool {
		// must match exactly
		if self.nextKey == value {
			self.nextId += 1
			updateNextKey()
			return true
		}
		else {
			return false
		}
	}

	private func updateNextKey() {
		self.nextKey = String(format: "item%02d", nextId)
	}

}
