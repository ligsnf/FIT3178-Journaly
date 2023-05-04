//
//  DayViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "memoryCell"

class DayViewController: UIViewController, DatabaseListener, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    var listenerType = ListenerType.memories
    weak var databaseController: DatabaseProtocol?
    
//    var date: Date = Date()
    var memories: [Memory] = []
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var memoriesCollectionView: UICollectionView!
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
        memoriesCollectionView.isHidden = selectedIndex != 0
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
        memoriesCollectionView.delegate = self
        memoriesCollectionView.dataSource = self
        memoriesCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createLayoutSection()), animated: false)
        
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
    
    func createLayoutSection() -> NSCollectionLayoutSection {
        let memorySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let memoryLayout = NSCollectionLayoutItem(layoutSize: memorySize)
        memoryLayout.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(140))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [memoryLayout])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)

        return layoutSection
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UICollectionViewDataSource
    
    func onMemoriesChange(change: DatabaseChange, memories: [Memory]) {
        self.memories = memories
        self.memoriesCollectionView.reloadData()
    }
    
    func onDaysChange(change: DatabaseChange, days: [Day]) {
        // Do nothing
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return memories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemoryCell
    
        // Configure the cell
        cell.configure(memory: memories[indexPath.row])
        return cell
    }
    
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
