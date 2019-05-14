//
//  TrampolineViewController.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit
import RxSwift

class TrampolineViewController: UIViewController {

	private var disposeBag = DisposeBag()

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

	private func registerObservers() {
		Maestro.ready()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in self?.navigateNext() })
			.disposed(by: disposeBag)
	}

	private func disposeObservers() {
		disposeBag = DisposeBag()
	}

	private func navigateNext() {
		performSegue(withIdentifier: "Main", sender: nil)
	}

}
