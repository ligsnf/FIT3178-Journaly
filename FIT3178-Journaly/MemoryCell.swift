//
//  MemoryCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 3/5/2023.
//

import UIKit

class MemoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var textContentLabel: UILabel!
    @IBOutlet var imagesCollectionView: UICollectionView!
    
    var images: [String]?
    
    // MARK: - View
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .systemCyan.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        size.height = max(size.height, 90)
        return size
    }

    
    // MARK: - Methods
    func configure(memory: Memory) {
        hideControls()
        
        // configure title and time
        titleLabel.text = memory.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        if let memoryDate = memory.datetime {
            timeLabel.text = dateFormatter.string(from: memoryDate)
        }
        
        // configure specific contents based on memory type
        switch memory.memoryType {
        case .text:
            textContentLabel.text = memory.text
            textContentLabel.isHidden = false
        case .images:
            images = memory.images
            imagesCollectionView.backgroundColor = .clear
            imagesCollectionView.reloadData()
            imagesCollectionView.isHidden = false
        default:
            // Handle other memory types here
            break
        }
    }
    
    
    func hideControls() {
        // hide all content views
        textContentLabel.isHidden = true
        imagesCollectionView.isHidden = true
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "memoryImageCell", for: indexPath) as! MemoryImageCell
        if let imageURL = images?[indexPath.row] {
            cell.configure(imageURL: imageURL)
        }
        return cell
    }

    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the size for your image cell
        return CGSize(width: 60, height: 60)
    }
    
}
