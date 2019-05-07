//
//  ItemEditViewModel.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/17/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RxSwift

enum ItemEditViewState: ViewModelState {
	case editing
	case aborted
	case completed
}

enum ItemEditViewIntent: ViewModelIntent {
	case value(String)
	case item(ItemProxy)
	case cancel
	case done
}

class ItemEditViewModel: ViewModel<ItemEditViewState, ItemEditViewIntent> {

	private let valueSubject = BehaviorSubject<String>(value: "")

	private var item: ItemProxy?

	private let canSaveSubject = BehaviorSubject<Bool>(value: false)

	private let parent: ItemListViewModel

	private let disposeBag = DisposeBag()

	required init(parent: ItemListViewModel) {
		self.parent = parent
		super.init()
	}

	func value() -> Observable<String> {
		return valueSubject
	}

	func canSave() -> Observable<Bool> {
		return canSaveSubject
	}
	
	override func createSubject() -> BehaviorSubject<ItemEditViewState> {
		return BehaviorSubject<ItemEditViewState>(value: .editing)
	}

	override func equality(_ a: ItemEditViewState, _ b: ItemEditViewState) -> Bool {
		return a == b
	}

	override func onIntent(_ intent: ItemEditViewIntent) {
		switch intent {
		case .value(let value):
			updateValue(value)
		case .item(let item):
			updateItem(item)
		case .cancel:
			cancelEdit()
			break
		case .done:
			doneEdit()
			break
		}
	}

	override func registerObservers() {
		let item = parent.selectedItem()
		item
			.filter({ $0 != nil })
			.flatMapLatest({ Observable.from(optional: $0) })
			.take(1)
			.do(onNext: { NSLog("item_edit.initial_item(\($0))") })
			.subscribe(onNext: { [weak self] initial in self?.updateItem(initial) })
			.disposed(by: disposeBag)

		valueSubject
			.map({ $0 != "" })
			.do(onNext: { NSLog("item_edit.can_save(\($0))") })
			.bind(to: canSaveSubject)
			.disposed(by: disposeBag)
	}

	private func cancelEdit() {
		guard expect(.editing) else { return }
		parent.onIntent(.cancel)
		transition(to: .aborted)
	}

	private func doneEdit() {
		guard expect(.editing) else { return }
		if let item = item {
			parent.onIntent(.saveItem(item))
		}
		transition(to: .completed)
	}

	private func updateValue(_ value: String) {
		guard expect(.editing) else { return }
		NSLog("item_edit.update_value(\(value))")

		item?.value = value
		valueSubject.onNext(value)
	}

	private func updateItem(_ item: ItemProxy) {
		guard expect(.editing) else { return }
		NSLog("item_edit.update_item(\(item))")
		self.item = item
		valueSubject.onNext(item.value)
	}

}
