//
//  RealmAccessor.swift
//  PMVPRealm
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import Foundation
import PMVP
import RealmSwift

public enum RealmResult<ResultType, E: Error> {
	case success(ResultType)
	case failure(E?)
}

open class RealmAccessor<K: Hashable & Comparable, L: Object & LocalObject, P: Proxy<K>, E: Error> {

	private let keyName: String

	private let converter: Converter<K, L, P>

	private let realmFactory: () -> Realm

	public init(keyName: String, converter: Converter<K, L, P>, realmFactory: @escaping () -> Realm) {
		self.keyName = keyName
		self.converter = converter
		self.realmFactory = realmFactory
	}

	final func objects(predicate: NSPredicate? = nil,
					   sortDescriptors: [NSSortDescriptor] = [],
					   limit: Int,
					   queue: DispatchQueue,
					   callback: @escaping (RealmResult<[P], E>) -> Void) {
		let realm = self.realmFactory()
		let resultCollection: Results<L>
		if predicate == nil {
			resultCollection = realm.objects(L.self)
		}
		else {
			guard let predicate = predicate else {
				queue.async { callback(RealmResult.failure(nil)) }
				return
			}
			resultCollection = realm.objects(L.self).filter(predicate)
		}
		var localObjects: [L] = []
		localObjects.reserveCapacity(resultCollection.count)
		for localObject in resultCollection {
			localObjects.append(localObject)
		}

		let converter = self.converter
		let proxies: [P] = localObjects.map({ converter.toProxy($0) })
		queue.async { callback(RealmResult.success(proxies)) }
	}

	final func upsert(_ objects: [K: P], queue: DispatchQueue, callback: @escaping (RealmResult<[P], E>) -> Void) {
		let keyName = self.keyName
		let realm = self.realmFactory()
		let lambda = { [weak self] in
			// first build a map of existing objects for the given keys
			let keys: [K] = [K](objects.keys)

			var existing: [K: L] = [:]
			existing.reserveCapacity(objects.count)

			let predicate = NSPredicate(format: "\(keyName) in %@", keys)
			let rawResults: Results<L> = realm.objects(L.self).filter(predicate)
			for obj in rawResults {
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
					_ = self?.insert(obj, in: realm)
				}
			}
		}
		do {
			try realm.write(lambda)
			let values: [P] = [P](objects.values)
			queue.async { callback(RealmResult.success(values)) }
		}
		catch {
			queue.async { callback(RealmResult.failure(nil)) }
		}
	}

	final func destroyObjects(for keys: [K], queue: DispatchQueue, callback: @escaping (RealmResult<[K], E>) -> Void) {
		let keyName = self.keyName
		let realm = self.realmFactory()
		let lambda = { 
			let predicate = NSPredicate(format: "\(keyName) in %@", keys)
			let objects = realm.objects(L.self).filter(predicate)
			realm.delete(objects)
		}
		do {
			try realm.write(lambda)
			queue.async { callback(RealmResult.success(keys)) }
		}
		catch {
			queue.async { callback(RealmResult.failure(nil)) }
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
