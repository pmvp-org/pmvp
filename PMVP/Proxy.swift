//
//  Proxy.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

public protocol Proxyable {
	associatedtype K: Hashable
	var key: K { get }
}

open class Proxy<K: Hashable>: Equatable, Proxyable {
	public var key: K

	public static func == (lhs: Proxy<K>, rhs: Proxy<K>) -> Bool {
		return false
	}

	public init(key: K) {
		self.key = key
	}
}
