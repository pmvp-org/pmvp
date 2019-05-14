//
//  RealmLocalStorage.swift
//  PMVPRealm
//
//  Created by Aubrey Goodman on 5/13/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RealmSwift

open class RealmLocalStorage<K: Hashable & Comparable, L: Object & LocalObject, P: Proxy<K>, E: Error>: LocalStorage<K, L, P, E> {

	private let realmFactory: () -> Realm

	private let keyName: String

	public init(realmFactory: @escaping () -> Realm, keyName: String, converter: Converter<K, L, P>) {
		self.realmFactory = realmFactory
		self.keyName = keyName
		super.init(converter: converter)
	}

	final func objects(predicate: NSPredicate? = nil,
					   sortDescriptors: [NSSortDescriptor] = [],
					   limit: Int = 1000,
					   queue: DispatchQueue,
					   callback: @escaping (RealmResult<[P], E>) -> Void) {

		let realm = self.realmFactory()
		let converter = self.converter

		let localObjects: Results<L>
		if predicate == nil {
			localObjects = realm.objects(L.self)
		}
		else {
			guard let predicate = predicate else {
				queue.async { callback(RealmResult.failure(nil)) }
				return
			}
			localObjects = realm.objects(L.self).filter(predicate)
		}
		let proxies: [P] = localObjects[0..<min(limit, localObjects.count)].map({ converter.toProxy($0) })
		queue.async { callback(RealmResult.success(proxies)) }
	}

	final func upsert(_ objects: [K: P], queue: DispatchQueue, callback: @escaping (RealmResult<[P], E>) -> Void) {
		let keyName = self.keyName
		let realm = self.realmFactory()
		let lambda = { [weak self] in
			// first build a map of existing objects for the given keys
			let keys: [K] = [K](objects.keys)

			let predicate = NSPredicate(format: "\(keyName) in %@", keys)
			let resultCollection: Results<L> = realm.objects(L.self).filter(predicate)

			var existing: [K: L] = [:]
			existing.reserveCapacity(objects.count)

			for obj: L in resultCollection {
				if let key: K = obj.value(forKey: keyName) as? K {
					existing[key] = obj
				}
			}

			// now iterate through objects and insert or update as needed
			for (key, obj) in objects {
				if let existing: L = existing[key] {
					self?.update(existing, with: obj)
				}
				else {
					self?.insert(obj, in: realm)
				}
			}

			let values: [P] = [P](objects.values)
			queue.async { callback(.success(values)) }
		}
		do {
			try realm.write(lambda)
		}
		catch let error {
			queue.async { callback(RealmResult.failure(error as? E)) }
		}
	}

	final func destroyObjects(for keys: [K], queue: DispatchQueue, callback: @escaping (RealmResult<[K], E>) -> Void) {
		let keyName = self.keyName
		let realm = self.realmFactory()
		let lambda = {
			let predicate = NSPredicate(format: "\(keyName) in %@", keys)
			let resultCollection: Results<L> = realm.objects(L.self).filter(predicate)
			realm.delete(resultCollection)
		}
		do {
			try realm.write(lambda)
			queue.async { callback(RealmResult.success(keys)) }
		}
		catch let error {
			queue.async { callback(RealmResult.failure(error as? E)) }
		}
	}

	// MARK: - Required Methods

	open func update(_ object: L, with proxy: P) {
		fatalError("unimplemented \(#function)")
	}

	open func insert(_ object: P, in realm: Realm) {
		fatalError("unimplemented \(#function)")
	}

}
