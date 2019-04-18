//
//  ItemLocalConverter.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemLocalConverter: Converter<ItemLocal, ItemProxy> {

	override func fromProxy(_ proxy: ItemProxy) -> ItemLocal {
		var local = ItemLocal(key: proxy.key, value: proxy.value)
		return local
	}

	override func toProxy(_ object: ItemLocal) -> ItemProxy {
		var proxy = ItemProxy(key: object.key, value: object.value)
		return proxy
	}

}
