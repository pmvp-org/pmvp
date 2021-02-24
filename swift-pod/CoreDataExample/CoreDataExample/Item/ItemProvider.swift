//
//  ItemProvider.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP

enum ItemError: Error {
	case unknown
}

class ItemProvider: Provider<String, ItemProxy, Item, ItemRemoteObject, ItemError, ItemLocalStorage, ItemRemoteStorage> {

}
