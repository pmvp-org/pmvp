//
//  ItemListViewController.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PMVP

class ItemListViewController: UIViewController {

	var viewModel: ItemListViewModel = ItemListViewModel()

	var disposeBag = DisposeBag()

	@IBOutlet private weak var createItemButton: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		NSLog("item_list.did_load")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NSLog("item_list.will_appear")
		registerObservers()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		disposeObservers()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? ItemTableViewController {
			dest.viewModel = viewModel
		}
		else if let dest = segue.destination as? ItemEditViewController {
			dest.listViewModel = viewModel
		}
	}

	private func registerObservers() {
		// create item button intent
		createItemButton.rx.tap
			.subscribe(onNext: { [weak self] _ in self?.viewModel.onIntent(.createItem) })
			.disposed(by: disposeBag)

		// when view model state is "creating" or "editing" perform CreateItem segue
		viewModel.state()
			.do(onNext: { NSLog("item_list_state(\($0))") })
			.filter({ state -> Bool in
				switch state {
				case .creating:
					return true
				case .editing(_):
					return true
				default:
					return false
				}
			})
			.subscribe(onNext: { [weak self] _ in self?.showItemDetail() })
			.disposed(by: disposeBag)
	}

	private func disposeObservers() {
		disposeBag = DisposeBag()
	}

	private func showItemDetail() {
		performSegue(withIdentifier: "CreateItem", sender: self)
	}

}
