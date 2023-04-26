//
//  SignUpViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - Methods
    // handle sign up
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
            navigationController?.setViewControllers([tabBarController], animated: false)
        }
    }
    
    // navigate to sign in page
    @IBAction func signInButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showSignIn", sender: nil)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = true
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
