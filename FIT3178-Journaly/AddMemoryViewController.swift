//
//  AddMemoryViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class AddMemoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Properties
    var usersReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var contentTitleLabel: UILabel!
    
    var imageArray: [UIImage] = []
    let imagePickerController = UIImagePickerController()
    var imagesCollectionView: UICollectionView?
    
    // MARK: - Methods
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func memoryTypeChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            clearAllContentInputs()
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
        case 3:
            clearAllContentInputs()
        case 4:
            clearAllContentInputs()
        default:
            displayMessage(title: "Error", message: "Invalid memory type")
        }
    }
    
    func clearAllContentInputs() {
        textTextView.isHidden = true
        imagesCollectionView?.removeFromSuperview()
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
    
    private func setupImagesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

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

    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imagePickerController.delegate = self
        
        // Style text entry
        textTextView.layer.borderColor = UIColor.systemGray5.cgColor
        textTextView.layer.borderWidth = 1.0
        textTextView.layer.cornerRadius = 8.0
        textTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)

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
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Image Picker Controller Delegate
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



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
