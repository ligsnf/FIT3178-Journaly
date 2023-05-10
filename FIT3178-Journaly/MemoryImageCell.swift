//
//  MemoryImageCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 9/5/2023.
//

import UIKit

class MemoryImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func configure(imageURL: String) {
        if let url = URL(string: imageURL) {
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
