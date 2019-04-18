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
	case key(String)
	case value(String)
	case item(ItemProxy)
	case cancel
	case done
}

class ItemEditViewModel: ViewModel<ItemEditViewState, ItemEditViewIntent> {

	private let itemSubject = BehaviorSubject<ItemProxy>(value: ItemProxy(key: "", value: ""))

	private let keySubject = BehaviorSubject<String>(value: "")

	private let valueSubject = BehaviorSubject<String>(value: "")

	private let canEditKeySubject = BehaviorSubject<Bool>(value: false)

	private let canSaveSubject = BehaviorSubject<Bool>(value: false)

	private let parent: ItemListViewModel

	private let disposeBag = DisposeBag()

	required init(parent: ItemListViewModel) {
		self.parent = parent
		super.init()
	}

	func key() -> Observable<String> {
		return keySubject
	}

	func value() -> Observable<String> {
		return valueSubject
	}

	func canEditKey() -> Observable<Bool> {
		return canEditKeySubject
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
		case .key(let key):
			updateKey(key)
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
			.take(1)
			.map({ item -> ItemProxy in
				if let item = item {
					return item
				}
				else {
					fatalError("the horror!")
				}
			})
			.do(onNext: { NSLog("item_edit.initial_item(\($0))") })
			.bind(to: itemSubject)
			.disposed(by: disposeBag)

		itemSubject.map({ $0.key })
			.bind(to: keySubject)
			.disposed(by: disposeBag)
		itemSubject.map({ $0.value })
			.bind(to: valueSubject)
			.disposed(by: disposeBag)

		itemSubject
			.map({ $0.key != "" && $0.value != "" })
			.do(onNext: { NSLog("item_edit.can_save(\($0))") })
			.bind(to: canSaveSubject)
			.disposed(by: disposeBag)

		parent.state()
			.map({ $0 == .creating })
			.do(onNext: { NSLog("item_edit.can_edit_key(\($0))") })
			.bind(to: canEditKeySubject)
			.disposed(by: disposeBag)
	}

	private func cancelEdit() {
		guard expect(.editing) else { return }
		parent.onIntent(.cancel)
		transition(to: .aborted)
	}

	private func doneEdit() {
		guard expect(.editing) else { return }
		guard let item = try? itemSubject.value() else { return }
		parent.onIntent(.saveItem(ItemProxy(key: item.key, value: item.value)))
		transition(to: .completed)
	}

	private func updateKey(_ key: String) {
		guard expect(.editing) else { return }
		NSLog("item_edit.update_key(\(key))")
		let item = mutableItem()
		item.key = key
		itemSubject.onNext(item)
	}

	private func updateValue(_ value: String) {
		guard expect(.editing) else { return }
		NSLog("item_edit.update_value(\(value))")
		let item = mutableItem()
		item.value = value
		itemSubject.onNext(item)
	}

	private func updateItem(_ item: ItemProxy) {
		guard expect(.editing) else { return }
		NSLog("item_edit.update_item(\(item))")
		itemSubject.onNext(item)
	}

	private func mutableItem() -> ItemProxy {
		guard let item = try? itemSubject.value() else {
			fatalError("invalid mutable item state")
		}
		let mutableCopy = ItemProxy(key: item.key, value: item.value)
		return mutableCopy
	}

}
