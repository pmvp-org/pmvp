//
//  Maestro+MockItem.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 5/6/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import Foundation

extension Maestro {

	class func configure(localStorage: ItemMockLocalStorage, options: [String]) {
		let group = DispatchGroup()
		if options.contains("HasOneItem") {
			let proxy = ItemProxy(key: "item1", value: "eggs")
			group.enter()
			localStorage.update(proxy, queue: .global()) { _ in
				group.leave()
			}
		}
		else if options.contains("HasItems") {
			group.enter()
			let proxy1 = ItemProxy(key: "item1", value: "ham")
			let proxy2 = ItemProxy(key: "item2", value: "eggs")
			localStorage.update([proxy1, proxy2], queue: .global()) { _ in
				group.leave()
			}
		}
		_ = group.wait(timeout: .now() + .seconds(1))
	}

}
