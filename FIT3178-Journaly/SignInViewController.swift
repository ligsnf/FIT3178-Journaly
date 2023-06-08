//
//  SignInViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import Firebase

/// `SignInViewController` manages user sign in.
///
/// This view controller provides user interface and functionality for existing users to sign in to the application.
/// It communicates with an authentication provider (like Firebase Authentication or similar) to authenticate the user.
class SignInViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol? // Database controller instance for database operations
    var authHandle: AuthStateDidChangeListenerHandle? // Authentication state listener
    
    // Text fields for email and password
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: - Methods
    
    // This function is triggered when the sign in button is tapped
    @IBAction func signInButtonTapped(_ sender: Any) {
        // Ensures email and password fields are not empty
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        // Check if either email or password fields are empty and display a message if they are
        if email.isEmpty || password.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if email.isEmpty {
                errorMsg += "- Must provide an email\n"
            }
            if password.isEmpty {
                errorMsg += "- Must provide a password"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        // Try to sign in user with given email and password
        databaseController?.signInUser(email: email, password: password) { authResult, error in
            if let error = error {
                // Display error message if sign in fails
                self.displayMessage(title: "Could not sign in", message: error.localizedDescription)
                return
            }
        }
    }
    
    // This function is triggered when the sign up button is tapped
    @IBAction func signUpButtonTapped(_ sender: Any) {
        // Perform segue to the sign up view
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    

    // MARK: - View
    
    // This function is called when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up database controller from the app delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Setup gesture to dismiss keyboard on tap
        self.setupHideKeyboardOnTap()
        // Hide the navigation bar
        navigationController?.isNavigationBarHidden = true
    }
    
    // This function is called when the view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add listener for changes in authentication state
        authHandle = Auth.auth().addStateDidChangeListener {
            (auth, user) in
            // If user is signed in, perform segue
            guard user != nil else { return }
            
            if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    fatalError("Could not find main window")
                }
                windowScene.windows.first?.rootViewController = tabBarController
            }
        }
    }
    
    // This function is called when the view is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove authentication state change listener when view is disappearing
        guard let authHandle = authHandle else { return }
        Auth.auth().removeStateDidChangeListener(authHandle)
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
