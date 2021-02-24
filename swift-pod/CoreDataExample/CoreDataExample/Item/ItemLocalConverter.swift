//
//  ItemLocalConverter.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemLocalConverter: Converter<String, Item, ItemProxy> {

	override func fromProxy(_ proxy: ItemProxy) -> Item {
		fatalError()
	}

	override func toProxy(_ object: Item) -> ItemProxy {
		guard let key = object.itemId, let value = object.value else { fatalError() }
		let proxy = ItemProxy(key: key, value: value)
		return proxy
	}

}
