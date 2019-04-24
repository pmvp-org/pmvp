//
//  KeyedCollectionSubjectHolder.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/23/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

open class KeyedCollectionSubjectHolder<K: Hashable, T> {

	public var subjectMap: [K: BehaviorSubject<[T]>] = [:]

	private let scheduler: SchedulerType

	private let preloader: (K, BehaviorSubject<[T]>) -> Void

	public init(scheduler: SchedulerType, preloader: @escaping (K, BehaviorSubject<[T]>) -> Void = { _,_ in }) {
		self.scheduler = scheduler
		self.preloader = preloader
	}

	public final func subject(for key: K) -> Observable<[T]> {
		return findOrCreateSubject(for: key)
	}

	public final func notify(for key: K, objects: [T]) {
		if let subject = subjectMap[key] {
			subject.onNext(objects)
		}
	}

	// MARK: - Private methods

	private func findOrCreateSubject(for key: K) -> Observable<[T]> {
		if let existing = subjectMap[key] {
			return existing
		}
		else {
			let newSubject = BehaviorSubject<[T]>(value: [])
			preloader(key, newSubject)
			subjectMap[key] = newSubject
			return newSubject
				.observeOn(scheduler)
				.do(onDispose: { [weak self] in self?.clearInactiveSubject(for: key) })
		}
	}

	private func clearInactiveSubject(for key: K) {
		if let subject = subjectMap[key], !subject.hasObservers {
			subjectMap.removeValue(forKey: key)
		}
	}

}
