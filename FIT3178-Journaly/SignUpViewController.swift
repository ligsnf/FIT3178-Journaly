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
    var authStateHandle: AuthStateDidChangeListenerHandle?
    
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
        performSegue(withIdentifier: "showSignIn", sender: nil)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // databaseController setup
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // hide nav bar
        navigationController?.isNavigationBarHidden = true
    }
    
    // add listener for authentication state changes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if user != nil {
                // user is signed in, perform segue
                if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
                    self.navigationController?.setViewControllers([tabBarController], animated: false)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove listener when view controller is about to disappear
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
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
