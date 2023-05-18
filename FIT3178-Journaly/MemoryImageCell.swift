//
//  MemoryImageCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 9/5/2023.
//

import UIKit

class MemoryImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    weak var databaseController: DatabaseProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func configure(imageURL: String) {
        let imageName = imageURL.components(separatedBy: "/").last!
        let filename = "\(imageName).jpg"

        // Check if image exists in local storage
        if let cachedImage = databaseController?.loadImageData(filename: filename) {
            self.imageView.image = cachedImage
        } else if let url = URL(string: imageURL) {
            // Download the image if it doesn't exist locally
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    print("Error retrieving image: \(String(describing: error))")
                    return
                }
                guard let data = data else {
                    print("No data for image")
                    return
                }
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        self.imageView.image = image
                    }
                }
            }
            task.resume()
        }
    }

}
