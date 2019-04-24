//
//  SubjectHolder.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

open class SubjectHolder<T> {

	private let objectSubject: BehaviorSubject<T?>

	private let scheduler: SchedulerType

	public init(scheduler: SchedulerType, preloader: (BehaviorSubject<T?>) -> Void = { _ in }) {
		self.scheduler = scheduler
		self.objectSubject = BehaviorSubject<T?>(value: nil)
		preloader(objectSubject)
	}

	public final func subject() -> BehaviorSubject<T?> {
		return objectSubject
	}

	public final func notify(_ object: T?) {
		objectSubject.onNext(object)
	}

}
