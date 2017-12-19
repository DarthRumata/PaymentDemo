//
//  User.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {

  @objc dynamic var id: String = ""
  @objc dynamic var firstName: String = ""
  @objc dynamic var lastName: String = ""
  @objc dynamic var company: String = ""
  @objc dynamic var email: String = ""
  @objc dynamic var token: String = ""

  override static func primaryKey() -> String? {
    return "id"
  }

  static func findAll() -> Results<User> {
    return safeRealm().objects(User.self)
  }

  static func current() -> User? {
    let users = User.findAll()

    return users.first
  }

  static func deleteAll() throws {
    let realm = safeRealm()
    try realm.write {
      realm.delete(findAll())
    }
  }

}

