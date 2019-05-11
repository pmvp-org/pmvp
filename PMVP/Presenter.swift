//
//  Presenter.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  SPDX-License-Identifier: MIT
//  Copyright © 2019 Aubrey Goodman.
//

import RxSwift

open class Presenter<T: ViewModelState, N: ViewModelIntent> {

	public let viewModel: ViewModel<T, N>

	public var disposeBag: DisposeBag = DisposeBag()

	public init(viewModel: ViewModel<T, N>) {
		self.viewModel = viewModel
	}

	// MARK: - Optional Methods

	open func registerObservers() {
	}

	public final func disposeObservers() {
		disposeBag = DisposeBag()
	}

}
