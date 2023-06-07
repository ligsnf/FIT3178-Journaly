//
//  AddMemoryViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 10/5/2023.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage
import GiphyUISDK
import AVFoundation

class AddMemoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GiphyDelegate, CLLocationManagerDelegate, AudioRecorderViewControllerDelegate {
    
    // MARK: - Properties
    var usersReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    weak var databaseController: DatabaseProtocol?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var locationAuthorized = false
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var contentTitleLabel: UILabel!
    
    var imageArray: [UIImage] = []
    var imagesCollectionView: UICollectionView?
    
    var selectedGIF: GPHMedia?
    var selectedGIFView: GPHMediaView?
    var selectedGIFURL: String?
    var addGIFButton: UIButton?
    var deleteGIFButton: UIButton?
    
    var addAudioButton: UIButton?
    var recordedAudioURL: URL?
    
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

        // location setup
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse {
            locationAuthorized = false
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    // MARK: - Methods
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func memoryTypeChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            clearAllContentInputs()
            textTextView.isHidden = false
        case 1:
            clearAllContentInputs()
            setupImagesCollectionView()
            if let imagesCollectionView = imagesCollectionView {
                view.addSubview(imagesCollectionView)
                
                // Set up constraints
                imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imagesCollectionView.topAnchor.constraint(equalTo: contentTitleLabel.bottomAnchor, constant: 8),
                    imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    imagesCollectionView.heightAnchor.constraint(equalToConstant: 100)
                ])
                imagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
                imagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
            }
        case 2:
            clearAllContentInputs()
            setupGIFControls()
            if let addGIFButton = addGIFButton, let selectedGIFView = selectedGIFView {
                view.addSubview(addGIFButton)
//                view.addSubview(selectedGIFView) already added in the setupGIFControls()
                
                addGIFButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    addGIFButton.topAnchor.constraint(equalTo: contentTitleLabel.bottomAnchor, constant: 28),
                    addGIFButton.leadingAnchor.constraint(equalTo: contentTitleLabel.leadingAnchor),
                    addGIFButton.widthAnchor.constraint(equalToConstant: 60),
                    addGIFButton.heightAnchor.constraint(equalToConstant: 60)
                ])
                
                selectedGIFView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    selectedGIFView.topAnchor.constraint(equalTo: contentTitleLabel.bottomAnchor, constant: 28),
                    selectedGIFView.leadingAnchor.constraint(equalTo: contentTitleLabel.leadingAnchor),
                    selectedGIFView.trailingAnchor.constraint(equalTo: contentTitleLabel.trailingAnchor),
                ])
            }
            
        case 3:
            clearAllContentInputs()
            setupAudioControls()
            if let addAudioButton = addAudioButton {
                view.addSubview(addAudioButton)
                
                addAudioButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    addAudioButton.topAnchor.constraint(equalTo: contentTitleLabel.bottomAnchor, constant: 28),
                    addAudioButton.leadingAnchor.constraint(equalTo: contentTitleLabel.leadingAnchor),
                    addAudioButton.widthAnchor.constraint(equalToConstant: 60),
                    addAudioButton.heightAnchor.constraint(equalToConstant: 60)
                ])
            }
        case 4:
            clearAllContentInputs()
        default:
            displayMessage(title: "Error", message: "Invalid memory type")
        }
    }
    
    func clearAllContentInputs() {
        textTextView.isHidden = true
        imagesCollectionView?.removeFromSuperview()
        addGIFButton?.removeFromSuperview()
        selectedGIFView?.removeFromSuperview()
        addAudioButton?.removeFromSuperview()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text else {
            return
        }
        if title.isEmpty {
            displayMessage(title: "Error", message: "Must enter a title.")
        }
        var location: GeoPoint?
        if locationAuthorized, let currentLocation = self.currentLocation {
            location = GeoPoint(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: // text memory
            guard let text = textTextView.text else {
                return
            }
            if text.isEmpty {
                displayMessage(title: "Error", message: "Must enter text content.")
            }
            let _ = databaseController?.addMemory(title: title, type: MemoryType.text, location: location, text: text, images: nil, gif: nil)
            dismiss(animated: true, completion: nil)
        case 1: // images memory
            if imageArray.isEmpty {
                displayMessage(title: "Error", message: "Cannot save until an image has been selected!")
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else {
                displayMessage(title: "Error", message: "No user logged in!")
                return
            }
            var imageURLs: [String] = []
            let timestamp = UInt(Date().timeIntervalSince1970)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            // loop - upload each image in array
            let dispatchGroup = DispatchGroup()
            for (index, image) in imageArray.enumerated() {
                guard let data = image.jpegData(compressionQuality: 0.8) else {
                    print("Error: Image \(index) data could not be compressed")
                    return
                }
                let filename = "\(timestamp)_\(index).jpg"
                let imageRef = storageReference.child("\(userID)/\(timestamp)_\(index)")
                
                dispatchGroup.enter()
                let uploadTask = imageRef.putData(data, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        imageURLs.append("\(imageRef)")
                    }
                    dispatchGroup.leave()
                }

                let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDirectory = pathsList[0]
                let imageFile = documentDirectory.appendingPathComponent(filename)
            }

            dispatchGroup.notify(queue: .main) {
                let _ = self.databaseController?.addMemory(title: title, type: MemoryType.images, location: location, text: nil, images: imageURLs, gif: nil)
                self.dismiss(animated: true, completion: nil)
            }
        case 2: // GIF memory
            guard let gifURL = selectedGIFURL else {
                return
            }
            if gifURL.isEmpty {
                displayMessage(title: "Error", message: "Must select a GIF.")
            }
            let _ = databaseController?.addMemory(title: title, type: MemoryType.gif, location: location, text: nil, images: nil, gif: gifURL)
            dismiss(animated: true, completion: nil)
        default:
            displayMessage(title: "Error", message: "Invalid memory type")
        }
        
    }
    
    // MARK: - Images
    private func setupImagesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0

        imagesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        imagesCollectionView?.backgroundColor = .clear
        imagesCollectionView?.dataSource = self
        imagesCollectionView?.delegate = self
        imagesCollectionView?.register(AddMemoryImageCell.self, forCellWithReuseIdentifier: "addMemoryImageCell")

    }
    
    @objc func deleteImageButtonTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: imagesCollectionView)
        if let indexPath = imagesCollectionView?.indexPathForItem(at: point) {
            imageArray.remove(at: indexPath.item)
            imagesCollectionView?.reloadData()
        }
    }
    
    // Image Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageArray.append(pickedImage)
            imagesCollectionView?.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - GIFs
    private func setupGIFControls() {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(addGIFTapped), for: .touchUpInside)

        let plusIconImageView = UIImageView(image: UIImage(systemName: "plus"))
        plusIconImageView.tintColor = .gray
        plusIconImageView.contentMode = .center
        plusIconImageView.translatesAutoresizingMaskIntoConstraints = false

        let addLabel = UILabel()
        addLabel.text = "Add GIF"
        addLabel.font = UIFont.systemFont(ofSize: 8)
        addLabel.textAlignment = .center
        addLabel.textColor = .gray
        addLabel.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(plusIconImageView)
        button.addSubview(addLabel)

        NSLayoutConstraint.activate([
            plusIconImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            plusIconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10),
            plusIconImageView.widthAnchor.constraint(equalToConstant: 20),
            plusIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            addLabel.topAnchor.constraint(equalTo: plusIconImageView.bottomAnchor, constant: 4),
            addLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 2),
            addLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2)
        ])

        addGIFButton = button
        
        // Create a GPHMediaView
        let GIFView = GPHMediaView()
        GIFView.translatesAutoresizingMaskIntoConstraints = false
        GIFView.isHidden = true
        view.addSubview(GIFView)  // Add GIFView to the view
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.layer.cornerRadius = 15
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteGIFTapped), for: .touchUpInside)
        deleteButton.isHidden = true
        deleteButton.layer.shadowColor = UIColor.black.cgColor
        deleteButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        deleteButton.layer.shadowOpacity = 0.5
        deleteButton.layer.shadowRadius = 1
        // Add delete button to view
        view.addSubview(deleteButton)
        
        // Set constraints for delete button
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: GIFView.topAnchor, constant: 2),
            deleteButton.trailingAnchor.constraint(equalTo: GIFView.trailingAnchor, constant: -2),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        selectedGIFView = GIFView
        deleteGIFButton = deleteButton
    }
    
    @objc func addGIFTapped() {
        // Handle GIF selection logic
        let giphy = GiphyViewController()
        giphy.delegate = self
        present(giphy, animated: true, completion: nil)
    }
    
    @objc func deleteGIFTapped() {
        selectedGIF = nil
        selectedGIFView?.isHidden = true
        deleteGIFButton?.isHidden = true
        addGIFButton?.isHidden = false
    }
    
    // GIPHY
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        // you user tapped a GIF!
        selectedGIF = media
        guard let gifURL = media.url(rendition: .original, fileType: .webp) else {
            print("Invalid gif URL")
            return
        }
        selectedGIFURL = gifURL
        selectedGIFView?.setMedia(media)
        selectedGIFView?.isHidden = false
        deleteGIFButton?.isHidden = false
        addGIFButton?.isHidden = true
        giphyViewController.dismiss(animated: true, completion: nil)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        // your user dismissed the controller without selecting a GIF
    }
    
    
    // MARK: - Audio
    func setupAudioControls() {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(addAudioTapped), for: .touchUpInside)

        let plusIconImageView = UIImageView(image: UIImage(systemName: "plus"))
        plusIconImageView.tintColor = .gray
        plusIconImageView.contentMode = .center
        plusIconImageView.translatesAutoresizingMaskIntoConstraints = false

        let addLabel = UILabel()
        addLabel.text = "Add Audio"
        addLabel.font = UIFont.systemFont(ofSize: 8)
        addLabel.textAlignment = .center
        addLabel.textColor = .gray
        addLabel.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(plusIconImageView)
        button.addSubview(addLabel)

        NSLayoutConstraint.activate([
            plusIconImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            plusIconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10),
            plusIconImageView.widthAnchor.constraint(equalToConstant: 20),
            plusIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            addLabel.topAnchor.constraint(equalTo: plusIconImageView.bottomAnchor, constant: 4),
            addLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 2),
            addLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2)
        ])

        addAudioButton = button
    }
    
    @objc func addAudioTapped() {
        // Handle Audio selection logic here
        let audioRecorder = AudioRecorderViewController()
        audioRecorder.delegate = self
        present(audioRecorder, animated: true, completion: nil)
    }
    
    func didRecordAudio(_ controller: AudioRecorderViewController, didFinishRecording audioURL: URL) {
        // do something with audioURL, e.g. add it to your data model
        recordedAudioURL = audioURL
        addAudioButton?.isHidden = true
    }
    
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addMemoryImageCell", for: indexPath) as! AddMemoryImageCell
        
        if indexPath.item < imageArray.count {
            cell.imageView.image = imageArray[indexPath.item]
            cell.imageView.contentMode = .scaleAspectFill // fill the imageView
            cell.deleteButton.isHidden = false
            cell.imageView.layer.borderWidth = 0
            cell.plusIcon.isHidden = true
            cell.addLabel.isHidden = true
            cell.deleteButton.addTarget(self, action: #selector(deleteImageButtonTapped(_:)), for: .touchUpInside)
        } else {
            cell.imageView.image = nil
            cell.imageView.tintColor = .gray
            cell.imageView.contentMode = .center
            cell.deleteButton.isHidden = true
            cell.imageView.layer.borderColor = UIColor.gray.cgColor
            cell.imageView.layer.borderWidth = 1
            cell.imageView.layer.cornerRadius = 4
            cell.plusIcon.isHidden = false
            cell.addLabel.isHidden = false
            cell.addLabel.text = "Add photo"
        }
        
        return cell
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == imageArray.count {
            // handle add photo button clicked
            let controller = UIImagePickerController()
            controller.allowsEditing = false
            controller.delegate = self
            let actionSheet = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            }
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                controller.sourceType = .photoLibrary
                self.present(controller, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                actionSheet.addAction(cameraAction)
            }
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    

    // MARK: - Location
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationAuthorized = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
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
