//
//  ItemListViewModel.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RxSwift

enum ItemListViewState: ViewModelState {
	case initial
}

enum ItemListViewIntent: ViewModelIntent {
	case newItem
}

class ItemListViewModel: ViewModel<ItemListViewState, ItemListViewIntent> {

	var items: [ItemProxy] = []

	private let needsRefreshSubject = BehaviorSubject<Bool>(value: false)

	private let disposeBag = DisposeBag()

	override func registerObservers() {
		super.registerObservers()
		Maestro.Item.objects()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] items in self?.updateItems(items) })
			.disposed(by: disposeBag)
	}

	override func createSubject() -> BehaviorSubject<ItemListViewState> {
		return BehaviorSubject<ItemListViewState>(value: .initial)
	}

	func needsRefresh() -> Observable<Bool> {
		return needsRefreshSubject
	}
	
	private func updateItems(_ items: [ItemProxy]) {
		self.items = items
	}

}
