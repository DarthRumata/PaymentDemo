//
//  ViewController.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import UIKit
import Foundation
import BraintreeDropIn
import Braintree
import SwiftMessages

private let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJlYjE4M2U5ZTIwZjVjM2E2YTliYzFlM2I1MGM5MDZiYTQ3YTg2OWYxZWM4NzJmYjQ3ODdiZjFhN2YxMGFiN2NhfGNyZWF0ZWRfYXQ9MjAxNy0xMi0xM1QxMDoxNDo0MS45MzcyMjY2NjArMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="

private let demoUser = [
  "firstName": "Adam",
  "lastName": "Smith",
  "company": "The Wealth of Nations",
  "email": "adam.smith@gmail.com"
]


class ViewController: UIViewController {

  @IBOutlet weak var buyButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var userLabel: UILabel!

  fileprivate var user: User? {
    didSet {
      if let user = user {
        userLabel.text = "\(user.firstName) \(user.lastName): \(user.id)"
      } else {
        userLabel.text = nil
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    user = User.current()

  }

  // MARK: Actions

  @IBAction func buyItem(_ sender: Any) {
    guard let user = user else {
      showDropIn(token: clientToken)
      return
    }

    showDropIn(token: user.token)
  }
  @IBAction func registerCustomer(_ sender: Any) {
    NetworkClient.instance.registerUser(userData: demoUser) { (id) in
      guard let id = id else {
        return
      }
      _ = try? User.deleteAll()
      let user = User()
      user.id = id
      user.firstName = demoUser["firstName"]!
      user.lastName = demoUser["lastName"]!
      user.company = demoUser["company"]!
      user.email = demoUser["email"]!
      NetworkClient.instance.getToken(for: user) { (token) in
        guard let token = token else {
          let view = MessageViewBuilder.makeError(with: "Can;t get token")
          SwiftMessages.show(view: view)
          return
        }
        user.token = token
        _ = user.save()
        self.user = user
      }

    }
  }

  @IBAction func subscribeToPlan(_ sender: Any) {
    NetworkClient.instance.purchaseSubscription(withId: "vsmb", for: user!) { (success) in
      let view: MessageView
      if (success) {
        view = MessageViewBuilder.makeSuccess(text: "OK")
      } else {
        view = MessageViewBuilder.makeError(with: "Can't subscribe to plan")
      }
      SwiftMessages.show(view: view)
    }
  }

}

private extension ViewController {

  func showDropIn(token: String) {
    let request =  BTDropInRequest()
    request.amount = "10"
    request.threeDSecureVerification = true
    let dropIn = BTDropInController(authorization: token, request: request) { (controller, result, error) in
      controller.dismiss(animated: true, completion: nil)

      guard let result = result, let method = result.paymentMethod else {
        if let error = error {
          print("ERROR: \(error)")
        }
        return
      }

      if result.isCancelled {
        print("CANCELLED")
      } else {
        NetworkClient.instance.sendNonce(method.nonce, for: self.user!, withAmount: 10, completion: { (success) in
          print(success)
        })
      }
    }
    present(dropIn!, animated: true, completion: nil)
  }
  
}

