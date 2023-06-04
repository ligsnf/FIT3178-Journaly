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
    var authHandle: AuthStateDidChangeListenerHandle?
    
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
