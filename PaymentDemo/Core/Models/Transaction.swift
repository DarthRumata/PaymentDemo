//
//  Transaction.swift
//  PaymentDemo
//
//  Created by Rumata on 12/18/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import ObjectMapper

struct Transaction: ImmutableMappable {

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    return formatter
  }()

  let id: String
  let status: String
  let amount: String
  let createdAt: Date
  let creditCard: CreditCard?

  init(map: Map) throws {
    id = try map.value("id")
    status = try map.value("status")
    amount = try map.value("amount")
    createdAt = try map.value("createdAt", using: DateFormatterTransform(dateFormatter: Transaction.dateFormatter))
    creditCard = try? map.value("creditCard")
  }

}

struct CreditCard: ImmutableMappable {

  let iconURL: URL
  let maskedNumber: String

  init(map: Map) throws {
    iconURL = try map.value("imageUrl", using: URLTransform())
    maskedNumber = try map.value("maskedNumber")
  }

}
