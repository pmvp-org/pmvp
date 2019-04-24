//
//  CollectionSubjectHolder.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

open class CollectionSubjectHolder<T> {

	private let collectionSubject: BehaviorSubject<[T]>

	private let scheduler: SchedulerType

	public init(scheduler: SchedulerType, preloader: (BehaviorSubject<[T]>) -> Void = { _ in }) {
		self.scheduler = scheduler
		self.collectionSubject = BehaviorSubject<[T]>(value: [])
		preloader(collectionSubject)
	}

	public final func subject() -> Observable<[T]> {
		return collectionSubject
	}

	public final func notify(_ objects: [T]) {
		collectionSubject.onNext(objects)
	}

}
