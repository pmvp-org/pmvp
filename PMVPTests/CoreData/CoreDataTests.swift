//
//  CoreDataTests.swift
//  PMVPTests
//
//  Created by Aubrey Goodman on 5/1/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import XCTest
import CoreData
@testable import PMVP

class CoreDataTests: XCTestCase {

	private lazy var managedObjectModel: NSManagedObjectModel = {
		guard let modelUrl = Bundle.main.url(forResource: "PlaylistModel", withExtension: "momd") else {
			fatalError("failed to find data in bundle")
		}
		guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
			fatalError("failed to load data model")
		}
		return model
	}()

	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		do {
			try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
		} catch {
			XCTFail("failed to load in-memory store")
		}
		return coordinator
	}()

	typealias ContextFactory = () -> NSManagedObjectContext
	private var contextFactory: ContextFactory?

	override func setUp() {
		self.contextFactory = { [weak self] in
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			context.persistentStoreCoordinator = self?.persistentStoreCoordinator
			return context
		}
	}

	func testObjects() {
		// add two objects manually
		guard let contextFactory = contextFactory else {
			XCTFail("nil context")
			return
		}
		let context = contextFactory()
		context.performAndWait {
			if let playlist1 = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: context) as? CoreDataPlaylist {
				playlist1.key = "playlist1"
				playlist1.value = "Playlist 1"
			}
			if let playlist2 = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: context) as? CoreDataPlaylist {
				playlist2.key = "playlist2"
				playlist2.value = "Playlist 2"
			}
			if context.hasChanges {
				_ = try? context.save()
			}
		}

		let converter = Converter<String, CoreDataPlaylist, PlaylistProxy>()
		let playlistAccessor = PlaylistAccessor(contextFactory: contextFactory, entityName: "Playlist", keyName: "key", converter: converter)
		let didReceiveObjects = expectation(description: "did receive objects")
		playlistAccessor.objects(predicate: nil, sortDescriptors: [], limit: 10, queue: .global()) { (result) in
			switch result {
			case .success(let objects):
				var map: [String: CoreDataPlaylist] = [:]
				for obj in objects {
					if let key = obj.key {
						map[key] = obj
					}
				}
				if let p1 = map["playlist1"] {
					XCTAssertEqual(p1.key, "playlist1")
					XCTAssertEqual(p1.value, "Playlist 1")
				}
				if let p2 = map["playlist2"] {
					XCTAssertEqual(p2.key, "playlist2")
					XCTAssertEqual(p2.value, "Playlist 2")
				}
				if objects.count == 2 {
					didReceiveObjects.fulfill()
				}
			case .failure(let error):
				XCTFail(error?.localizedDescription ?? "")
			}
		}
		waitForExpectations(timeout: 1.0, handler: nil)
	}

	func testUpsert() {

	}

	func testDestroy() {

	}

}
