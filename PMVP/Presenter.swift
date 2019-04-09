//
//  Presenter.swift
//  PMVP
//
//  Created by Aubrey Goodman on 4/8/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import RxSwift

class Presenter<T: ViewModelState, N: ViewModelIntent> {

	let viewModel: ViewModel<T, N>

	var disposeBag: DisposeBag = DisposeBag()

	init(viewModel: ViewModel<T, N>) {
		self.viewModel = viewModel
	}

	// MARK: - Optional Methods

	func registerObservers() {
	}

	final func disposeObservers() {
		disposeBag = DisposeBag()
	}

}
