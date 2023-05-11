//
//  AddMemoryViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 10/5/2023.
//

import UIKit

class AddMemoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textTextView: UITextView!
    
    
    // MARK: - Methods
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text else {
            return
        }
        if title.isEmpty {
            displayMessage(title: "Error", message: "Must enter a title.")
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let type = MemoryType.text
            guard let text = textTextView.text else {
                return
            }
            if text.isEmpty {
                displayMessage(title: "Error", message: "Must enter text content.")
            }
            let _ = databaseController?.addMemory(title: title, type: type, text: text, images: nil)
            dismiss(animated: true, completion: nil)
        default:
            displayMessage(title: "Error", message: "Invalid memory type")
        }
        
        
    }
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Style text entry
        textTextView.layer.borderColor = UIColor.systemGray5.cgColor
        textTextView.layer.borderWidth = 1.0
        textTextView.layer.cornerRadius = 8.0
        textTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)

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
