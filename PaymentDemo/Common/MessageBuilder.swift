//
//  MessageBuilder.swift
//  PaymentDemo
//
//  Created by Rumata on 12/15/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import SwiftMessages

enum MessageViewBuilder {

  static func makeError(with text: String) -> MessageView {
    let view = MessageView.viewFromNib(layout: .MessageView)
    view.configureTheme(.error)
    view.button?.isHidden = true
    view.configureContent(title: "Error", body: text)

    return view
  }

  static func makeSuccess(text: String) -> MessageView {
    let view = MessageView.viewFromNib(layout: .MessageView)
    view.configureTheme(.success)
    view.button?.isHidden = true
    view.configureContent(title: "Success", body: text)

    return view
  }
  
}
