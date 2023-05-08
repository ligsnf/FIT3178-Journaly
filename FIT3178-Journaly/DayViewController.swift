//
//  DayViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "memoryCell"

class DayViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var listenerType = ListenerType.memories
    weak var databaseController: DatabaseProtocol?
    
//    var date: Date = Date()
    var memories: [Memory] = []
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var memoriesTableView: UITableView!
    @IBOutlet var memoriesMapView: MKMapView!
    @IBOutlet var addMemoryButton: UIButton!
    
    // MARK: - Methods
    func updateTitle() {
        if let currentDate = databaseController?.getDate() {
            self.navigationItem.title = formatDate(currentDate)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        let components = calendar.dateComponents([.day], from: date, to: Date())
        
        // set navigation bar title
        if calendar.isDateInToday(date) {
            return "Today"
        }
        if let daysDifference = components.day, daysDifference == 1 {
            return "Yesterday"
        } else if let daysDifference = components.day, daysDifference > 1 && daysDifference <= 8 {
            dateFormatter.dateFormat = "EEEE, d MMMM"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "d MMMM, yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    @IBAction func addMemoryButtonTapped(_ sender: Any) {
    }
    
    @objc func segmentedControlValueChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        memoriesTableView.isHidden = selectedIndex != 0
        memoriesMapView.isHidden = selectedIndex == 0
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        
        // databaseController setup
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Configure segmented control
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Configure collection view
        memoriesTableView.delegate = self
        memoriesTableView.dataSource = self
        
        // Update title and view
        segmentedControlValueChanged()
        updateTitle()
        
        // Set the button's tint colour and shadow
        addMemoryButton.tintColor = UIColor.systemGray5
        addMemoryButton.layer.shadowColor = UIColor.black.cgColor
        addMemoryButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addMemoryButton.layer.shadowRadius = 3
        addMemoryButton.layer.shadowOpacity = 0.3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTitle()
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UITableViewDataSource
    
    func onMemoriesChange(change: DatabaseChange, memories: [Memory]) {
        self.memories = memories
        self.memoriesTableView.reloadData()
    }
    
    func onDaysChange(change: DatabaseChange, days: [Day]) {
        // Do nothing
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MemoryCell
        cell.configure(memory: memories[indexPath.row])
        return cell
    }

    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle the selection of the memory at indexPath.row
    }
     */
    

    // MARK: UITableViewDelegate


}
