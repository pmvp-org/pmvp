//
//  ItemListViewModel.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import PMVP
import RxSwift
import RxCocoa

enum ItemListViewState: ViewModelState {
	case loading
	case valid
	case creating
	case editing(ItemProxy)

	static func ==(_ a: ItemListViewState, _ b: ItemListViewState) -> Bool {
		switch a {
		case .loading:
			switch b {
			case .loading:
				return true
			default:
				return false
			}
		case .valid:
			switch b {
			case .valid:
				return true
			default:
				return false
			}
		case .creating:
			switch b {
			case .creating:
				return true
			default:
				return false
			}
		case .editing(let itemA):
			switch b {
			case .editing(let itemB):
				return itemA == itemB
			default:
				return false
			}
		}
	}
}

enum ItemListViewIntent: ViewModelIntent {
	case edit(ItemProxy)
	case createItem
	case cancel
	case saveItem(ItemProxy)
}

class ItemListViewModel: ViewModel<ItemListViewState, ItemListViewIntent> {

	private let itemsSubject = BehaviorSubject<[ItemProxy]>(value: [])

	private let selectedItemSubject = BehaviorSubject<ItemProxy?>(value: nil)

	private let disposeBag = DisposeBag()

	func items() -> Observable<[ItemProxy]> {
		return itemsSubject
	}

	func selectedItem() -> Observable<ItemProxy?> {
		return selectedItemSubject
	}

	override func createSubject() -> BehaviorSubject<ItemListViewState> {
		return BehaviorSubject<ItemListViewState>(value: .loading)
	}

	override func equality(_ a: ItemListViewState, _ b: ItemListViewState) -> Bool {
		return a == b
	}

	override func onIntent(_ intent: ItemListViewIntent) {
		switch intent {
		case .edit(let item):
			editItem(item)
		case .createItem:
			createItem()
		case .cancel:
			cancelItem()
		case .saveItem(let item):
			saveItem(item)
		}
	}

	override func registerObservers() {
		super.registerObservers()
		let itemsObservable = Maestro.Item.objects()
			.observeOn(MainScheduler.asyncInstance)

		itemsObservable
			.distinctUntilChanged()
			.bind(to: itemsSubject)
			.disposed(by: disposeBag)

		itemsObservable
			.take(1)
			.subscribe(onNext: { [weak self] _ in self?.transition(to: .valid) })
			.disposed(by: disposeBag)
	}

	private func cancelItem() {
		selectedItemSubject.onNext(nil)
		transition(to: .valid)
	}

	private func createItem() {
		guard expect(.valid) else { return }
		let newItem = Maestro.Item.buildItem(value: "")
		selectedItemSubject.onNext(newItem)
		transition(to: .creating)
	}

	private func editItem(_ item: ItemProxy) {
		guard expect(.valid) else { return }
		selectedItemSubject.onNext(item)
		transition(to: .editing(item))
	}

	private func saveItem(_ item: ItemProxy) {
		Maestro.Item.update(item, queue: .main) { [weak self] (result) in
			self?.transition(to: .valid)
		}
	}
}
