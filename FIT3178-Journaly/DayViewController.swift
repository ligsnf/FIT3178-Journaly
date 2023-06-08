//
//  DayViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "memoryCell"

/// `DayViewController` is the controller for the Day View in the application.
/// It shows the memories for a particular day, handles UI interactions,
/// and communicates with the database controller to perform necessary operations.
class DayViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    // MARK: - Properties
    var listenerType = ListenerType.memories // Type of database listener for this view controller
    weak var databaseController: DatabaseProtocol? // Instance of the database controller for database operations
    
    var memories: [Memory] = [] // Array to hold memories to be displayed
    
    // UI elements
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var memoriesTableView: UITableView!
    @IBOutlet var memoriesMapView: MKMapView!
    @IBOutlet var addMemoryButton: UIButton!
    
    // MARK: - Methods
    
    /// Updates the title of the navigation bar
    func updateTitle() {
        if let currentDate = databaseController?.getDate() {
            self.navigationItem.title = formatDate(currentDate)
        }
    }
    
    /// Formats a date object into a string for display
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
    
    /// Function to handle when the 'add memory' button is tapped
    @IBAction func addMemoryButtonTapped(_ sender: Any) {
    }
    
    /// Function to handle when the value of the segmented control changes
    @objc func segmentedControlValueChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        memoriesTableView.isHidden = selectedIndex != 0
        memoriesMapView.isHidden = selectedIndex == 0
    }
    
    /// Function to handle when the 'back' button is tapped
    @objc func backButtonTapped() {
        if let tabBarController = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController {
            tabBarController.selectedIndex = 0
        }
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
        
        memoriesMapView.delegate = self
        
        // Add bar button item
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle(" Home", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.sizeToFit()
        // Make the button call a method when it's tapped
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        // Wrap the button in a UIBarButtonItem
        let barButtonItem = UIBarButtonItem(customView: button)
        // Set the navigation bar's left bar button item
        navigationItem.leftBarButtonItem = barButtonItem
        
        // Configure segmented control
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Configure table view
        memoriesTableView.delegate = self
        memoriesTableView.dataSource = self
        memoriesTableView.rowHeight = UITableView.automaticDimension
        memoriesTableView.estimatedRowHeight = 120
        
        
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
        // Update title and listen for changes in the database
        updateTitle()
        databaseController?.addListener(listener: self)
        
        // only show add memory button if it is current date
        let currentDate = Date()
        if let dateFromDatabase = databaseController?.getDate(), Calendar.current.isDate(dateFromDatabase, inSameDayAs: currentDate) {
            // Show the button
            addMemoryButton.isHidden = false
        } else {
            // Hide the button
            addMemoryButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop listening for changes in the database
        databaseController?.removeListener(listener: self)
    }

    // DatabaseListener methods
    func onMemoriesChange(change: DatabaseChange, memories: [Memory]) {
        self.memories = memories
        self.memoriesTableView.reloadData()
        self.loadMapAnnotations()
    }
    
    func onDaysChange(change: DatabaseChange, days: [Day]) {
        // Do nothing
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Map
    
    /// Loads annotations onto the map view
    func loadMapAnnotations() {
        // clear map annotations
        memoriesMapView.removeAnnotations(memoriesMapView.annotations)
        memoriesMapView.removeOverlays(memoriesMapView.overlays) // Also clear all overlays
        
        // add annotations from memories
        var locations: [LocationAnnotation] = []
        for memory in memories {
            if let location = memory.location {
                var subtitle: String? = nil
                if let text = memory.text {
                    // limit number of characters for subtitle
                    if text.count > 40 {
                        let index = text.index(text.startIndex, offsetBy: 40)
                        subtitle = "\(text[..<index])..."
                    } else {
                        subtitle = text
                    }
                }
                let annotation = LocationAnnotation(title: memory.title ?? nil, subtitle: subtitle ?? nil, lat: location.latitude, long: location.longitude)
                locations.append(annotation)
                memoriesMapView.addAnnotation(annotation)
            }
        }
        
        // Draw path between locations
        var coordinates: [CLLocationCoordinate2D] = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        memoriesMapView.addOverlay(polyline)
        
        // if no locations
        if locations.isEmpty {
            if segmentedControl.selectedSegmentIndex == 1 {
                if memories.isEmpty {
                    displayMessage(title: "No memories", message: "Add some memories to see their locations")
                } else {
                    displayMessage(title: "No locations", message: "None of your memories have locations, try turning on location services and add some memories")
                }
            }
        } else {
            mapShowAllAnnotations()
        }
    }

    // MKMapViewDelegate method
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    /// Focuses the map view on the given annotation
    func focusMapOn(annotation: MKAnnotation) {
        memoriesMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        memoriesMapView.setRegion(zoomRegion, animated: true)
    }
    
    /// Fits all annotations into the visible region of the map view
    func mapShowAllAnnotations() {
        memoriesMapView.showAnnotations(memoriesMapView.annotations, animated: true)
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let mapRectToDisplay = memoriesMapView.mapRectThatFits(memoriesMapView.visibleMapRect, edgePadding: mapEdgePadding)
        memoriesMapView.setVisibleMapRect(mapRectToDisplay, edgePadding: mapEdgePadding, animated: true)
    }

    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of memories to be displayed
        return memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configures and returns a cell for the memory at indexPath.row
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
