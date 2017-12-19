//
//  Object.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import RealmSwift

extension Object {

  func save() -> Bool {
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(self)
      }
    } catch (let error) {
      print(error)
      return false
    }

    return true
  }

  static func safeRealm() -> Realm {
    do {
      return try Realm()
    } catch (let error) {
      print(error)
    }
    fatalError()
  }

}
