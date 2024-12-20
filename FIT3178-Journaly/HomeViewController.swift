//
//  HomeViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit

/// `HomeViewController` is the primary screen the users see after they log in to the application.
///
/// This view controller provides an interface for the user to navigate through different parts of the application.
/// The HomeViewController might also display some basic user information and other relevant details depending on your application's specifics.
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol? // Instance of the database controller for database operations
    
    @IBOutlet var datePicker: UIDatePicker!
    
    
    // MARK: - Methods
    @IBAction func todayButtonTapped(_ sender: Any) {
        let today = Date()
        datePicker.date = today
        segueToDayView(today)
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        let selectedDate = datePicker.date
        let currentDate = Date()
        
        if selectedDate >= currentDate {
            displayMessage(title: "Error", message: "Cannot select a future date.")
            return
        }
        
        segueToDayView(selectedDate)
    }
    
    // Function to segue to the DayView with a given date
    func segueToDayView(_ date: Date) {
        if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController,
           let navigationController = tabBarController.viewControllers?[1] as? UINavigationController,
           let dayViewController = navigationController.viewControllers.first as? DayViewController {
            databaseController?.setDate(date)
            databaseController?.setupMemoriesListener()
            dayViewController.updateTitle()
            tabBarController.selectedIndex = 1
        }
    }
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set up the database controller from the app delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

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
