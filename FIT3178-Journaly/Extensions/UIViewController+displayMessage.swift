//
//  UIViewController+displayMessage.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

extension UIViewController {
    
    // This function displays an alert message with the provided title and message
    func displayMessage(title: String, message: String) {
        // Create an alert controller with the given title and message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a dismiss button to the alert controller
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
}
