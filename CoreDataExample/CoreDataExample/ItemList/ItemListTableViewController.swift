//
//  ItemListTableViewController.swift
//  CoreDataExample
//
//  Created by Aubrey Goodman on 5/12/19.
//  Copyright © 2019 Aubrey Goodman. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {

	var itemListViewModel: ItemListViewModel!
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemListViewModel.items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") else { return UITableViewCell() }
		let item = itemListViewModel.items[indexPath.row]
		cell.textLabel?.text = item.value
		return cell
	}

}
