//
//  CardCell.swift
//  PaymentDemo
//
//  Created by Rumata on 12/15/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import Reusable

class CardCell: UITableViewCell, NibReusable {

  @IBOutlet weak var cardNumberLabel: UILabel!
  @IBOutlet weak var expireDateLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!

  func configure(with card: Card) {
    cardNumberLabel.text = card.number
    typeLabel.text = card.type
    expireDateLabel.text = "\(card.month)/\(card.year)"
  }

}
