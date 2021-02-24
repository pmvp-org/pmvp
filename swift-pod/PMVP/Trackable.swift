//
//  Trackable.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/22/19.
//  SPDX-License-Identifier: MIT
//  Copyright © 2019 Aubrey Goodman.
//

public protocol Trackable {

	var localUpdatedAt: Date { get set }

	var remoteUpdatedAt: Date { get set }

}
