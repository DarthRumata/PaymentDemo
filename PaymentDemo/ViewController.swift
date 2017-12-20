//
//  ViewController.swift
//  PaymentDemo
//
//  Created by Rumata on 12/13/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import UIKit
import Foundation
import SwiftMessages
import Stripe

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

  fileprivate lazy var paymentContext: STPPaymentContext = STPPaymentContext(customerContext: self.customerContext)
  fileprivate let customerContext = STPCustomerContext(keyProvider: NetworkClient.instance.keyProvider)

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
    self.paymentContext.delegate = self
    self.paymentContext.hostViewController = self
    self.paymentContext.paymentAmount = 1000 // This is in cents, i.e. $50 USD
  }

  // MARK: Actions

  @IBAction func buyItem(_ sender: Any) {
    guard user != nil else {
      return
    }

    paymentContext.requestPayment()
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
      _ = user.save()
      self.user = user
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

  @IBAction func showPaymentPicker(_ sender: Any) {
    guard user != nil else {
      return
    }

    showDropIn()
  }

}

extension ViewController: STPPaymentContextDelegate {

  func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    buyButton.isEnabled = paymentContext.selectedPaymentMethod != nil
    UIApplication.shared.isNetworkActivityIndicatorVisible = paymentContext.loading
    print("chnage")
  }

  func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
    NetworkClient.instance.createCharge(for: user!, withAmount: paymentContext.paymentAmount, source: paymentResult.source) { (error) in
      let view: MessageView
      if (error == nil) {
        view = MessageViewBuilder.makeSuccess(text: "OK")
      } else {
        view = MessageViewBuilder.makeError(with: "Can't pay")
      }
      SwiftMessages.show(view: view)
      completion(error)
    }
  }

  func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
    if let error = error {
      let view = MessageViewBuilder.makeError(with: error.localizedDescription)
      SwiftMessages.show(view: view)
    }
    print(status)
  }

  func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
    let view = MessageViewBuilder.makeError(with: error.localizedDescription)
    SwiftMessages.show(view: view)
  }

  func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
    let upsGround = PKShippingMethod()
    upsGround.amount = 0
    upsGround.label = "UPS Ground"
    upsGround.detail = "Arrives in 3-5 days"
    upsGround.identifier = "ups_ground"
    let fedEx = PKShippingMethod()
    fedEx.amount = 5.99
    fedEx.label = "FedEx"
    fedEx.detail = "Arrives tomorrow"
    fedEx.identifier = "fedex"
    completion(.valid, nil, [upsGround, fedEx], upsGround)
  }
  
}

private extension ViewController {

  func showDropIn() {
    paymentContext.presentPaymentMethodsViewController()
  }
  
}

