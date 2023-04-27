//
//  UIViewController+displayMessage.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

extension UIViewController {
    
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    
}
