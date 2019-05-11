//
//  ViewModel.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  SPDX-License-Identifier: MIT
//  Copyright © 2019 Aubrey Goodman.
//

import RxSwift

open class ViewModel<T: ViewModelState, N: ViewModelIntent> {

	private var stateSubject: BehaviorSubject<T>!

	public init() {
		self.stateSubject = createSubject()
		registerObservers()
	}

	public final func state() -> Observable<T> {
		return stateSubject
	}

	// MARK: - Required Methods

	open func createSubject() -> BehaviorSubject<T> {
		fatalError("unimplemented \(#function)")
	}

	open func equality(_ a: T, _ b: T) -> Bool {
		fatalError("unimplemented \(#function)")
	}

	open func onIntent(_ intent: N) {
		fatalError("unimplemented \(#function)")
	}

	// MARK: - Optional Methods

	open func registerObservers() {
	}

	open func willTransition(to state: T) {
	}

	open func didTransition(to state: T) {
	}

	// MARK: - Shared Methods

	public final func expect(_ state: T) -> Bool {
		guard let currentState: T = try? stateSubject.value() else { return false }
		return equality(currentState, state)
	}

	public final func expect(in options: [T]) -> Bool {
		guard let currentState: T = try? stateSubject.value() else { return false }
		for option in options {
			if equality(currentState, option) {
				return true
			}
		}
		return false
	}

	public final func transition(to state: T) {
		willTransition(to: state)
		stateSubject.onNext(state)
		didTransition(to: state)
	}

}
