//
//  CoreDataManager.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {

	typealias ContextFactory = () -> NSManagedObjectContext
	static func contextFactory() -> ContextFactory {
		let factory: ContextFactory = { () -> NSManagedObjectContext in
			guard let delegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
			return delegate.persistentContainer.newBackgroundContext()
		}
		return factory
	}

}
