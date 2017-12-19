//
//  TransactionListController.swift
//  PaymentDemo
//
//  Created by Rumata on 12/18/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class TransactionListController: UITableViewController {

  fileprivate var transactions = [Transaction]()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(cellType: TransactionCell.self)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    tableView.tableFooterView = UIView(frame: CGRect.zero)

    loadTransactions()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transactions.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let transaction = transactions[indexPath.row]

    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TransactionCell.self)
    cell.configure(with: transaction)

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let chooser = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)

    let refundAction = UIAlertAction(title: "Refund", style: .default) { (action) in
      chooser.dismiss(animated: true, completion: nil)
      let transaction = self.transactions[indexPath.row]
      self.refundTransaction(transaction)
    }
    chooser.addAction(refundAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      chooser.dismiss(animated: true, completion: nil)
    }
    chooser.addAction(cancelAction)

    present(chooser, animated: true, completion: nil)
  }

}

private extension TransactionListController {

  func loadTransactions() {
    NetworkClient.instance.getTransactions(for: User.current()!) { transactions, error in
      self.transactions = transactions
      self.tableView.reloadData()
    }
  }

  func refundTransaction(_ transaction: Transaction) {
    NetworkClient.instance.refundTransaction(transaction) { (success) in
      let view: MessageView
      if (success) {
        view = MessageViewBuilder.makeSuccess(text: "Added")
      } else {
        view = MessageViewBuilder.makeError(with: "")
      }
      SwiftMessages.show(view: view)
    }
  }

}
