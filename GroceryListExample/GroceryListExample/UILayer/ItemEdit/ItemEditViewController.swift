//
//  ItemEditViewController.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/17/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import RxSwift

class ItemEditViewController: UIViewController {

	@IBOutlet private weak var keyText: UITextField!

	@IBOutlet private weak var valueText: UITextField!

	@IBOutlet private weak var cancelButton: UIBarButtonItem!

	@IBOutlet private weak var doneButton: UIBarButtonItem!

	var listViewModel: ItemListViewModel!

	private var viewModel: ItemEditViewModel!

	private var presenter: ItemEditPresenter!

	private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
		viewModel = ItemEditViewModel(parent: listViewModel)
		presenter = ItemEditPresenter(viewModel: viewModel,
									  keyText: keyText,
									  valueText: valueText,
									  cancelButton: cancelButton,
									  doneButton: doneButton)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		registerObservers()
		presenter.registerObservers()
	}

	private func registerObservers() {
		// when user changes key, update model to match
		keyText.rx.observe(String.self, "text")
			.skip(1)
			.do(onNext: { NSLog("item_edit.user_key(\($0))") })
			.subscribe(onNext: { [weak self] key in
				if let key = key {
					self?.viewModel.onIntent(.key(key))
				}
			})
			.disposed(by: disposeBag)

		// when user changes value, update model to match
		valueText.rx.observe(String.self, "text")
			.skip(1)
			.do(onNext: { NSLog("item_edit.user_value(\($0))") })
			.subscribe(onNext: { [weak self] value in
				if let value = value {
					self?.viewModel.onIntent(.value(value))
				}
			})
			.disposed(by: disposeBag)

		cancelButton.rx.tap
			.subscribe(onNext: { [weak self] _ in self?.cancelIntent() })
			.disposed(by: disposeBag)

		doneButton.rx.tap
			.subscribe(onNext: { [weak self] _ in self?.doneIntent() })
			.disposed(by: disposeBag)

		listViewModel.state()
			.filter({ state -> Bool in
				switch state {
				case .creating:
					return false
				case .editing:
					return false
				default:
					return true
				}
			})
			.subscribe(onNext: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
			.disposed(by: disposeBag)

		listViewModel.state()
			.map({ state -> String in
				switch state {
				case .creating:
					return "Create Item"
				case .editing:
					return "Edit Item"
				default:
					return ""
				}
			})
			.bind(to: self.rx.title)
			.disposed(by: disposeBag)
	}

	private func disposeObservers() {
		disposeBag = DisposeBag()
	}

	private func cancelIntent() {
		viewModel.onIntent(.cancel)
	}

	private func doneIntent() {
		viewModel.onIntent(.done)
	}

}