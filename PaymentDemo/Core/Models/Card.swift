//
//  Card.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import RealmSwift

enum PaymentService: Int {
  case BrainTree
}

class Card: Object {

  @objc dynamic var id: String = ""
  @objc dynamic var paymentService: Int = 0
  @objc dynamic var cardDescription: String = ""
  @objc dynamic var number: String = ""
  @objc dynamic var type: String = ""
  @objc dynamic var month = 0
  @objc dynamic var year = 0
  @objc dynamic var userId: String = ""

  override static func primaryKey() -> String? {
    return "id"
  }

  static func findAll() -> Results<Card> {
    return safeRealm().objects(Card.self)
  }

  func delete() throws {
    let realm = Object.safeRealm()
    try realm.write {
      realm.delete(self)
    }
  }
  
}
