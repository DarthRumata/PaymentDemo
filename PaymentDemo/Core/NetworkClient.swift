//
//  NetworkClient.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

private let basePath = "http://localhost:3000"

struct NetworkClient {

  static let instance = NetworkClient(basePath: basePath)

  private let pathBuilder: PathBuilder
  private let parser = ResponseParser()
  private let sessionManager: SessionManager

  private init(basePath: String) {
    pathBuilder = PathBuilder(serverURL: URL(string: basePath)!)
    let configuration = URLSessionConfiguration.default
    var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    defaultHeaders["Content-Type"] = "application/json"
    configuration.httpAdditionalHeaders = defaultHeaders
    sessionManager = Alamofire.SessionManager(configuration: configuration)
  }

  func registerUser(userData: [String: Any], completion: @escaping (String?) -> Void) {
    sessionManager.request(pathBuilder.customerURL, method: .post, parameters: userData, encoding: JSONEncoding.default).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          completion(data["customer_id"] as? String)
        } catch (let error) {
          print(error)
          completion(nil)
        }

        print(value)

      case .failure(let error):
        completion(nil)
        print(error)
      }
    }
  }

  func getToken(for user: User, completion: @escaping (String?) -> Void) {
    sessionManager.request(pathBuilder.tokenURL, parameters: ["customer_id": user.id], encoding: URLEncoding.queryString).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          completion(data["token"] as? String)
        } catch (let error) {
          print(error)
          completion(nil)
        }

        print(value)

      case .failure(let error):
        completion(nil)
        print(error)
      }
    }
  }

  func sendNonce(_ nonce: String, for user: User, withAmount amount: Float, completion: @escaping (Bool) -> Void) {
    sessionManager.request(pathBuilder.paymentsURL(withCustomerId: user.id), method: .post, parameters: ["nonce": nonce, "amount": amount], encoding: JSONEncoding.default).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          print(data)
          completion(true)
        } catch (let error) {
          print(error)
          completion(false)
        }

        print(value)

      case .failure(let error):
        completion(false)
        print(error)
      }
    }
  }

  func addPaymentMethod(_ nonce: String, for user: User, completion: @escaping (Bool) -> Void) {
    sessionManager.request(pathBuilder.paymentMethodURL(withCustomerId: user.id), method: .post, parameters: ["nonce": nonce], encoding: JSONEncoding.default).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          print(data)
          completion(true)
        } catch (let error) {
          print(error)
          completion(false)
        }

        print(value)

      case .failure(let error):
        completion(false)
        print(error)
      }
    }
  }

  func purchaseSubscription(withId planId: String, for user: User, completion: @escaping (Bool) -> Void) {
    sessionManager.request(pathBuilder.subscriptionsURL(withCustomerId: user.id), method: .post, parameters: ["planId": planId], encoding: JSONEncoding.default).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          print(data)
          completion(true)
        } catch (let error) {
          print(error)
          completion(false)
        }

        print(value)

      case .failure(let error):
        completion(false)
        print(error)
      }
    }
  }

  func getTransactions(for user: User, completion: @escaping ([Transaction], Error?) -> Void) {
    sessionManager.request(pathBuilder.transactionsURL(withCustomerId: user.id), method: .get).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parseToArray(value: value)
          let transactions = (try? Mapper<Transaction>().mapArray(JSONArray: data)) ?? []
          completion(transactions, nil)
        } catch (let error) {
          completion([], error)
        }

        print(value)

      case .failure(let error):
        completion([], error)
      }
    }
  }

  func refundTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
    sessionManager.request(pathBuilder.refundTransactionURL(with: transaction.id), method: .post).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        do {
          let data = try self.parser.parse(value: value)
          completion(true)
        } catch (let error) {
          completion(false)
        }

        print(value)

      case .failure(let error):
        completion(false)
      }
    }
  }

}

struct ResponseParser {

  enum ParserError: Error {
    case invalidFormat
  }

  init() {}

  func parse(value: Any) throws -> [String: Any] {
    guard let envelope = value as? [String: Any], let data = envelope["data"] as? [String: Any] else {
      throw ParserError.invalidFormat
    }

    return data
  }

  func parseToArray(value: Any) throws -> [[String: Any]] {
    guard let envelope = value as? [String: Any], let data = envelope["data"] as? [[String: Any]] else {
      throw ParserError.invalidFormat
    }

    return data
  }


}

struct PathBuilder {

  private let serverURL: URL

  init(serverURL: URL) {
    self.serverURL = serverURL
  }

  var braintreeURL: URL {
    return serverURL.appendingPathComponent("braintree")
  }

  var customerURL: URL {
    return braintreeURL.appendingPathComponent("customer")
  }

  func refundTransactionURL(with transationId: String) -> URL {
    return braintreeURL.appendingPathComponent("transaction").appendingPathComponent(transationId).appendingPathComponent("refund")
  }

  var tokenURL: URL {
    return braintreeURL.appendingPathComponent("token")
  }

  func paymentsURL(withCustomerId id: String) -> URL {
    return customerURL.appendingPathComponent(id).appendingPathComponent("payments")
  }

  func paymentMethodURL(withCustomerId id: String) -> URL {
    return customerURL.appendingPathComponent(id).appendingPathComponent("paymentMethod")
  }

  func subscriptionsURL(withCustomerId id: String) -> URL {
    return customerURL.appendingPathComponent(id).appendingPathComponent("subscriptions")
  }

  func transactionsURL(withCustomerId id: String) -> URL {
    return customerURL.appendingPathComponent(id).appendingPathComponent("transactions")
  }
  
}
