//
//  UIViewController+setupHideKeyboardOnTap.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 4/6/2023.
//

import UIKit

extension UIViewController {
    // Call this function once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        // Add gesture recognizer to view and navigation bar
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    // This function creates and returns a gesture recognizer that will trigger end editing when a tap is detected
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
