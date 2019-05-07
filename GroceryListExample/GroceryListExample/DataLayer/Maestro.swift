//
//  Maestro.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

final class Maestro {

	private static var instance: Maestro!

	private static let readySubject = BehaviorSubject<Bool>(value: false)

	let itemProvider: ItemProvider

	private init(itemProvider: ItemProvider) {
		self.itemProvider = itemProvider
	}

	class func ready() -> Observable<Bool> {
		return readySubject
	}

	class func start(options: [String]) {
		let itemProvider: ItemProvider
		let useMocks = options.contains("UseMocks")
		if useMocks {
			let localConv = ItemLocalConverter()
			let itemLocal = ItemMockLocalStorage(converter: localConv)
			configure(localStorage: itemLocal, options: options)
			let remoteConv = ItemRemoteConverter()
			let itemRemote = ItemMockRemoteStorage(converter: remoteConv)
			itemProvider = ItemProvider(queueName: "item", localStorage: itemLocal, remoteStorage: itemRemote)
		}
		else {
			let itemLocalConverter = ItemLocalConverter()
			let itemLocal = ItemLocalStorage(converter: itemLocalConverter)
			let itemRemoteConverter = ItemRemoteConverter()
			let itemRemote = ItemRemoteStorage(converter: itemRemoteConverter)
			itemProvider = ItemProvider(queueName: "item", localStorage: itemLocal, remoteStorage: itemRemote)
		}
		instance = Maestro(itemProvider: itemProvider)
		NSLog("maestro.ready")
		readySubject.onNext(true)
	}

}

extension Maestro {
	class var Item: ItemProvider { return instance.itemProvider }
}
