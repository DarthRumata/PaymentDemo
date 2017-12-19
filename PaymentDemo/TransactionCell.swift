//
//  TransactionCell.swift
//  PaymentDemo
//
//  Created by Rumata on 12/18/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import Reusable
import Kingfisher

class TransactionCell: UITableViewCell, NibReusable {

  private static let formatter = DateFormatter(withFormat: "dd.MM.YYYY", locale: "us")

  @IBOutlet private weak var icon: UIImageView!
  @IBOutlet private weak var statusLabel: UILabel!
  @IBOutlet private weak var numberLabel: UILabel!
  @IBOutlet private weak var amountLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!

  func configure(with transaction: Transaction) {
    icon.kf.setImage(with: transaction.creditCard?.iconURL)
    numberLabel.text = transaction.creditCard?.maskedNumber
    amountLabel.text = "\(transaction.amount) USD"
    dateLabel.text = TransactionCell.formatter.string(from: transaction.createdAt)
    statusLabel.text = transaction.status
  }

}
