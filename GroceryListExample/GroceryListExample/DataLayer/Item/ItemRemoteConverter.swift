//
//  ItemRemoteConverter.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemRemoteConverter: Converter<String, ItemRemote, ItemProxy> {

	override func fromProxy(_ proxy: ItemProxy) -> ItemRemote {
		fatalError("unused")
	}

	override func toProxy(_ object: ItemRemote) -> ItemProxy {
		fatalError("unused")
	}

}
