//
//  ViewModel.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

class ViewModel<T: ViewModelState, N: ViewModelIntent> {

	private var stateSubject: BehaviorSubject<T>!

	init() {
		self.stateSubject = createSubject()
	}

	final func state() -> Observable<T> {
		return stateSubject
	}

	// MARK: - Required Methods

	func createSubject() -> BehaviorSubject<T> {
		fatalError("unimplemented \(#function)")
	}

	func equality(_ a: T, _ b: T) -> Bool {
		fatalError("unimplemented \(#function)")
	}

	func onIntent(_ intent: N) {
		fatalError("unimplemented \(#function)")
	}

	// MARK: - Optional Methods

	func willTransition(to state: T) {
	}

	func didTransition(to state: T) {
	}

	// MARK: - Shared Methods

	final func expect(_ state: T) -> Bool {
		guard let currentState: T = try? stateSubject.value() else { return false }
		return equality(currentState, state)
	}

	final func expect(in options: [T]) -> Bool {
		guard let currentState: T = try? stateSubject.value() else { return false }
		for option in options {
			if equality(currentState, option) {
				return true
			}
		}
		return false
	}

	final func transition(to state: T) {
		willTransition(to: state)
		stateSubject.onNext(state)
		didTransition(to: state)
	}

}
