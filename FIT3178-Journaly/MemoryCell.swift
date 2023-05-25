//
//  MemoryCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 3/5/2023.
//

import UIKit
import GiphyUISDK

class MemoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var textContentLabel: UILabel!
    var imagesCollectionView: UICollectionView!
    var gifView: GPHMediaView?
    
    var images: [String]? {
        didSet {
            imagesCollectionView?.reloadData()
        }
    }
    
    // MARK: - View
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .systemCyan.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

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
    
    private func setupImagesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0

        imagesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        imagesCollectionView?.backgroundColor = .clear
        imagesCollectionView?.dataSource = self
        imagesCollectionView?.delegate = self
        imagesCollectionView?.register(MemoryImageCell.self, forCellWithReuseIdentifier: "memoryImageCell")

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
            setupImagesCollectionView()
            if let imagesCollectionView = imagesCollectionView {
                contentView.addSubview(imagesCollectionView)
                
                // Set up constraints
                imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imagesCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                    imagesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
                    imagesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    imagesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    imagesCollectionView.heightAnchor.constraint(equalToConstant: 90)
                ])
                imagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
                imagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            }
            imagesCollectionView?.reloadData()
        case .gif:
            let gifView = GPHMediaView()
            guard let gifURL = memory.gif else { return }
            gifView.loadAsset(at: gifURL)
            contentView.addSubview(gifView)
            // Set constraints for gif
            gifView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gifView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                gifView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                gifView.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
                gifView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            ])
            self.gifView = gifView
        default:
            // Handle other memory types here
            break
        }
    }
    
    
    func hideControls() {
        // hide all content views
        textContentLabel.isHidden = true
        imagesCollectionView?.removeFromSuperview()
        gifView?.removeFromSuperview()
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
