//
//  Trackable.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/22/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

public protocol Trackable {

	var localUpdatedAt: Date { get set }

	var remoteUpdatedAt: Date { get set }

}
