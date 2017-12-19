//
//  CardListController.swift
//  PaymentDemo
//
//  Created by Rumata on 12/15/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Braintree
import SwiftMessages

class CardListController: UITableViewController {

  fileprivate let user = User.current()!
  private lazy var cards: Results<Card> = Card.findAll().filter("userId == %@", self.user.id)
  private var notificationToken: NotificationToken?

  override func viewDidLoad() {
    tableView.register(cellType: CardCell.self)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    tableView.tableFooterView = UIView(frame: CGRect.zero)

    notificationToken = cards.observe { [weak self] (changes) in
      guard let tableView = self?.tableView else { return }

      switch changes {
      case .initial:
        // Results are now populated and can be accessed without blocking the UI
        tableView.reloadData()
      case .update(_, let deletions, let insertions, let modifications):
        // Query results have changed, so apply them to the UITableView
        tableView.beginUpdates()
        tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                             with: .automatic)
        tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                             with: .automatic)
        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                             with: .automatic)
        tableView.endUpdates()
      default:
        break
      }
    }
  }

  deinit {
    notificationToken?.invalidate()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cards.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let card = cards[indexPath.row]
    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CardCell.self)
    cell.configure(with: card)

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let chooser = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
    let card = self.cards[indexPath.row]
    let storeAction = UIAlertAction(title: "Add to Vault", style: .default) { (action) in
      chooser.dismiss(animated: true, completion: nil)
      self.addCardToVault(card: card)
    }
    chooser.addAction(storeAction)
    let buyAction = UIAlertAction(title: "Buy with card", style: .default) { (action) in
      chooser.dismiss(animated: true, completion: nil)
      self.buy(with: card)
    }
    chooser.addAction(buyAction)
    let deleteAction = UIAlertAction(title: "Delete card", style: .destructive) { (action) in
      chooser.dismiss(animated: true, completion: nil)
      _ = try? card.delete()
    }
    chooser.addAction(deleteAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      chooser.dismiss(animated: true, completion: nil)
    }
    chooser.addAction(cancelAction)

    present(chooser, animated: true, completion: nil)
  }

}

private extension CardListController {

  func addCardToVault(card: Card) {
    tokenizeCard(card) { tokenizedCard in
      NetworkClient.instance.addPaymentMethod(tokenizedCard.nonce, for: self.user) { (result) in
        let view: MessageView
        if (result) {
          view = MessageViewBuilder.makeSuccess(text: "Added")
        } else {
          view = MessageViewBuilder.makeError(with: "")
        }
        SwiftMessages.show(view: view)
      }
    }
  }

  func buy(with card: Card) {
    tokenizeCard(card) { tokenizedCard in
      NetworkClient.instance.sendNonce(tokenizedCard.nonce, for: self.user, withAmount: 10, completion: { (success) in
        print(success)
      })
    }
  }

  func tokenizeCard(_ card: Card, completion: @escaping (BTCardNonce) -> Void) {
    let braintreeClient = BTAPIClient(authorization: user.token)!
    let cardClient = BTCardClient(apiClient: braintreeClient)
    let cardInfo = BTCard(number: card.number, expirationMonth: String(card.month), expirationYear: String(card.year), cvv: nil)
    cardClient.tokenizeCard(cardInfo) { (tokenizedCard, error) in
      guard let tokenizedCard = tokenizedCard else {
        if let error = error {
          let error = MessageViewBuilder.makeError(with: error.localizedDescription)
          SwiftMessages.show(view: error)
        }
        return
      }

      completion(tokenizedCard)
    }
  }
  
}
