//
//  AccountViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

/// `AccountViewController` handles the user's account information and sign out action.
///
/// This view controller shows user's account details like name and email, and allows user to sign out from the app.
class AccountViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol? /// An object that conforms to the `DatabaseProtocol` which is used for database operations.
    
    // name and email labels of signed in user
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    
    // MARK: - Methods
    
    /// Triggers when the sign out button is tapped.
    /// This method signs the user out from the app and navigates back to the login screen.
    @IBAction func signOutButtonTapped(_ sender: Any) {
        databaseController?.signOutUser() { error in
            if error != nil {
                // Handle error here
                self.displayMessage(title: "Could not sign out", message: "An error occurred while signing out.")
            } else {
                // Navigate back to the login screen
                if let loginNavigationController = (UIApplication.shared.delegate as? AppDelegate)?.loginNavigationController {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        fatalError("Could not find main window")
                    }
                    windowScene.windows.first?.rootViewController = loginNavigationController
                }
                
                // Set back to home view controller
                if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            }
        }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // databaseController setup
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// This method updates the user's name and email label.
    override func viewWillAppear(_ animated: Bool) {
        guard let user = databaseController?.userSnap?.data() else { return }
        nameLabel.text = user["name"] as? String
        emailLabel.text = user["email"] as? String
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
