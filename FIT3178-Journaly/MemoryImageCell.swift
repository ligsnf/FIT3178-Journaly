//
//  MemoryImageCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 9/5/2023.
//

import UIKit
import FirebaseStorage

class MemoryImageCell: UICollectionViewCell {
    var imageView: UIImageView!
    weak var databaseController: DatabaseProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageURL: String) {
        let imageName = imageURL.components(separatedBy: "/").last!
        let filename = "\(imageName).jpg"
        
        // Check if image exists in local storage
        if let cachedImage = databaseController?.loadImageData(filename: filename) {
            self.imageView.image = cachedImage
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)

            // Download the image from Firebase Storage if it doesn't exist locally
            let storageRef = Storage.storage().reference(forURL: imageURL)
            storageRef.write(toFile: fileURL) { url, error in
                if let error = error {
                    // Handle any errors
                    print("Error downloading image: \(error)")
                } else {
                    DispatchQueue.main.async {
                        guard let cachedImage = self.databaseController?.loadImageData(filename: filename) else { return }
                        self.imageView.image = cachedImage
                    }
                }
            }
        }
    }

}
