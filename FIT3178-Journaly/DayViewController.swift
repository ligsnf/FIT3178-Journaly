//
//  DayViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "memoryCell"

struct Memory {
    let title: String
    let description: String
    let date: Date
}

class DayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    var date: Date = Date()
    var dateString: String?
    var memories: [Memory] = [
        Memory(title: "The Great Coffee Disaster", description: "I thought I could save time by brewing coffee with my hair dryer. Big mistake. My kitchen is now a coffee-scented sauna. Time to take a break and visit a coffee shop.", date: Date()),
        Memory(title: "Tuna Salad Surprise", description: "I tried to make a healthy tuna salad for lunch, but I accidentally grabbed a can of cat food instead. It smelled awful, but I figured it couldn't be that bad. I was wrong. Note to self: label the cans.", date: Date()),
        Memory(title: "My Cat's Fashion Show", description: "My cat has been walking around with a piece of string tied around her neck like it's a necklace. I tried to take it off, but she wouldn't let me. Now she's strutting around like she's on the catwalk. Who knew cats had a sense of fashion?", date: Date()),
        Memory(title: "The Great Laundry Fiasco", description: "I accidentally mixed a red sock with my whites in the laundry. Now everything is pink. I guess I'll have to wear pink shirts and underwear for a while. At least it's a new fashion statement.", date: Date()),
        Memory(title: "The Talking Plant", description: "I swear my plant talked to me today. It said, 'Water me, or I'll die.' I'm not sure if I'm losing my mind or if my plant is just really needy. Either way, I need to start talking to more humans.", date: Date()),
        Memory(title: "Morning", description: "I woke up.", date: Date()),
        Memory(title: "Noon", description: "I napped.", date: Date()),
        Memory(title: "Night", description: "I slept.", date: Date()),
    ]

    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var memoriesCollectionView: UICollectionView!
    @IBOutlet var memoriesMapView: MKMapView!
    @IBOutlet var addMemoryButton: UIButton!
    
    // MARK: - Methods
    func updateTitle() {
        self.navigationItem.title = formatDate(date)
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        let components = calendar.dateComponents([.day], from: date, to: Date())
        
        // set date string for firestore id
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateString = dateFormatter.string(from: date)
        
        // set navigation bar title
        if calendar.isDateInToday(date) {
            return "Today"
        }
        if let daysDifference = components.day, daysDifference > 0 && daysDifference <= 7 {
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
        
        // Configure segmented control
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Configure collection view
        memoriesCollectionView.delegate = self
        memoriesCollectionView.dataSource = self
        
        
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UICollectionViewDataSource

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
