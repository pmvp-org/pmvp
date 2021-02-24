//
//  ItemListViewController.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ItemListViewController: UIViewController {

	var viewModel: ItemListViewModel!

	@IBOutlet private weak var addButton: UIBarButtonItem!

	private var disposeBag = DisposeBag()

	override func awakeFromNib() {
		super.awakeFromNib()
		viewModel = ItemListViewModel()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		registerObservers()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		disposeObservers()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dst = segue.destination as? ItemListTableViewController {
			dst.itemListViewModel = viewModel
		}
	}
	
	private func registerObservers() {
		addButton.rx.tap
			.subscribe(onNext: { [weak self] _ in self?.viewModel.onIntent(.newItem) })
			.disposed(by: disposeBag)
	}

	private func disposeObservers() {
		disposeBag = DisposeBag()
	}

}
