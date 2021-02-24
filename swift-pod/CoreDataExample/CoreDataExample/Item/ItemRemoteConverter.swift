//
//  ItemRemoteConverter.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

class ItemRemoteConverter: Converter<String, ItemRemoteObject, ItemProxy> {

	override func fromProxy(_ proxy: ItemProxy) -> ItemRemoteObject {
		fatalError()
	}

	override func toProxy(_ object: ItemRemoteObject) -> ItemProxy {
		fatalError()
	}
	
}
