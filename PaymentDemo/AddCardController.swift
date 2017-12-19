//
//  AddCardController.swift
//  PaymentDemo
//
//  Created by Rumata on 12/15/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class AddCardController: UIViewController {

  @IBOutlet weak var numberField: UITextField!
  @IBOutlet weak var monthField: UITextField!
  @IBOutlet weak var yearField: UITextField!

  private let user = User.current()!

  @IBAction func saveCard(_ sender: Any) {
    guard let number = numberField.text, let month = monthField.text, let year = yearField.text else {
      let error = MessageViewBuilder.makeError(with: "Fill all fields!")
      SwiftMessages.show(view: error)
      return
    }

    let card = Card(value: [
      "id": ProcessInfo.processInfo.globallyUniqueString,
      "number": number,
      "month": Int(month)!,
      "year": Int(year)!,
      "userId": user.id
      ])
    _ = card.save()
    navigationController!.popViewController(animated: true)
  }

}
