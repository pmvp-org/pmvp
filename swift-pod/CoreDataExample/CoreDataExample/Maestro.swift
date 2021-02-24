//
//  Maestro.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

class Maestro {

	private static var instance: Maestro!

	private static let readySubject = BehaviorSubject<Bool>(value: false)

	private let itemProvider: ItemProvider

	private init(itemProvider: ItemProvider) {
		self.itemProvider = itemProvider
	}

	class func start() {
		guard instance == nil else { return }
		let contextFactory = CoreDataManager.contextFactory()
		let localConv = ItemLocalConverter()
		let itemLocal = ItemLocalStorage(entityName: "Item", keyName: "itemId", converter: localConv, contextFactory: contextFactory)
		let remoteConv = ItemRemoteConverter()
		let itemRemote = ItemRemoteStorage(converter: remoteConv)
		let itemProvider = ItemProvider(queueName: "item.queue", localStorage: itemLocal, remoteStorage: itemRemote)
		instance = Maestro(itemProvider: itemProvider)
		NSLog("maestro.ready")
		readySubject.onNext(true)
	}

	class func ready() -> Observable<Bool> {
		return readySubject
	}

}

extension Maestro {

	class var Item: ItemProvider { return instance.itemProvider }
	
}
