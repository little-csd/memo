//
//  KeyboardGuardian.swift
//  memo
//
//  Created by stevecai on 2021/12/26.
//

import Foundation
import UIKit

let KEYBOARD = KeyboardGuardian()

final class KeyboardGuardian: ObservableObject {
    
    @Published var keyboardIsHidden = true

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    


    @objc func keyBoardWillShow(notification: Notification) {
        if keyboardIsHidden {
            keyboardIsHidden = false
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        if !keyboardIsHidden {
            keyboardIsHidden = true
        }
    }
}
