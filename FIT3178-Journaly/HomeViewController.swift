//
//  HomeViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Methods
    @IBAction func dayButtonTapped(_ sender: Any) {
        if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
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
