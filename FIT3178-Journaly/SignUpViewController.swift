//
//  SignUpViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol?
    var authHandle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!

    // MARK: - Methods
    // handle sign up
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            return
        }
        
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
        
        if password != confirmPassword {
            displayMessage(title: "Error", message: "Passwords must match")
            return
        }
        
        databaseController?.signUpUser(email: email, password: password, name: name) { authResult, error in
            if let error = error {
                self.displayMessage(title: "Could not sign up", message: error.localizedDescription)
                return
            }
        }
    }
    
    // navigate to sign in page
    @IBAction func signInButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // databaseController setup
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // dismiss keyboard when tapped anywhere
        self.setupHideKeyboardOnTap()
        // hide nav bar
        navigationController?.isNavigationBarHidden = true
    }
    
    // add listener for authentication state changes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authHandle = Auth.auth().addStateDidChangeListener {
            (auth, user) in
            guard user != nil else { return }
            // user is signed in, perform segue
            if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    fatalError("Could not find main window")
                }
                windowScene.windows.first?.rootViewController = tabBarController
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove listener when view controller is about to disappear
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
