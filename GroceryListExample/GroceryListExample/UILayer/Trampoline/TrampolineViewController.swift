//
//  TrampolineViewController.swift
//  GroceryListExample
//
//  Created by Aubrey Goodman on 4/16/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import RxSwift

class TrampolineViewController: UIViewController {

	private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// navigate to main when maestro indicates ready=>true
		Maestro.ready()
			.do(onNext: { value in NSLog("trampoline.ready -> \(value)") })
			.filter({ $0 })
			.observeOn(MainScheduler.asyncInstance)
			.subscribe(onNext: { [weak self] _ in self?.navigateToMain() })
			.disposed(by: disposeBag)
	}

	private func navigateToMain() {
		NSLog("trampoline.start")
		performSegue(withIdentifier: "Start", sender: nil)
	}

}
