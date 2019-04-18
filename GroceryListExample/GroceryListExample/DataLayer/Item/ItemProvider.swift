//
//  ItemProvider.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RxSwift

class ItemProvider: Provider<String, ItemProxy, ItemLocal, ItemRemote, ItemLocalStorage, ItemRemoteStorage> {

	override func createSubject() -> BehaviorSubject<ItemProxy?> {
		return BehaviorSubject<ItemProxy?>(value: nil)
	}

	override func createCollectionSubject() -> BehaviorSubject<[ItemProxy]> {
		return BehaviorSubject<[ItemProxy]>(value: [])
	}

	override func createKeyListSubject() -> BehaviorSubject<[String]> {
		return BehaviorSubject<[String]>(value: [])
	}

	override func key(for object: ItemProxy?) -> String? {
		return object?.key
	}

}
