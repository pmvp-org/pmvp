//
//  ItemProvider.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RxSwift

enum ItemError: Error {
	case unknown
}

class ItemProvider: Provider<String, ItemProxy, ItemLocal, ItemRemote, ItemError, ItemLocalStorage, ItemRemoteStorage> {

	private let keyFactory = ItemKeyFactory()

	func buildItem(value: String) -> ItemProxy {
		let key = keyFactory.generate()
		let newItem = ItemProxy(key: key, value: value)
		_ = keyFactory.claim(key)
		return newItem
	}

}
