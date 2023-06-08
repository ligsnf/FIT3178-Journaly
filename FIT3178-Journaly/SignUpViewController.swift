//
//  SignUpViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import Firebase

/// `SignUpViewController` manages user registration.
///
/// This view controller provides user interface and functionality for new users to register an account in the application.
/// It communicates with an authentication provider (like Firebase Authentication or similar) to create a new user.
class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol? // Instance of the database controller for database operations
    var authHandle: AuthStateDidChangeListenerHandle? // Authentication state listener
    
    // Text fields for name, email, password, and confirm password
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!

    // MARK: - Methods
    
    // This function is triggered when the sign up button is tapped
    @IBAction func signUpButtonTapped(_ sender: Any) {
        // Check if any of the text fields are empty, and if so, return
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            return
        }
       
        // Check if any of the fields are empty, and display an error message if they are
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if email.isEmpty {
                errorMsg += "- Must provide an email\n"
            }
            if password.isEmpty {
                errorMsg += "- Must provide a password\n"
            }
            if confirmPassword.isEmpty {
                errorMsg += "- Must confirm password"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        // Check if passwords match and display an error message if they don't
        if password != confirmPassword {
            displayMessage(title: "Error", message: "Passwords must match")
            return
        }
        
        // Try to sign up the user with given email, password and name
        databaseController?.signUpUser(email: email, password: password, name: name) { authResult, error in
            if let error = error {
                // Display error message if sign up fails
                self.displayMessage(title: "Could not sign up", message: error.localizedDescription)
                return
            }
        }
    }
    
    // This function is triggered when the sign in button is tapped, leading back to the sign in screen
    @IBAction func signInButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - View
    
    // This function is called when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the database controller from the app delegate
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
            // If user is signed up, perform segue
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
