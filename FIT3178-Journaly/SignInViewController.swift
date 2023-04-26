//
//  SignInViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol?
    var authStateHandle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: - Methods
    // handle sign in
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
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
        
        databaseController?.signInUser(email: email, password: password) { authResult, error in
            if let error = error {
                self.displayMessage(title: "Could not sign in", message: error.localizedDescription)
                return
            }
        }
    }
    
    // navigate to sign up page
    @IBAction func signUpButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showSignUp", sender: nil)
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
