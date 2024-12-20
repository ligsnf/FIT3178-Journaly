//
//  MemoryCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 3/5/2023.
//

import UIKit
import GiphyUISDK
import FirebaseStorage

/// `MemoryCell` is a custom `UITableViewCell` subclass that handles displaying memory details, including title, time, text content, images, gifs, and audio.
///
/// It conforms to `UICollectionViewDelegate`, `UICollectionViewDataSource`, and `UICollectionViewDelegateFlowLayout` for managing a collection of memory images.
class MemoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    /// Memory UI Labels
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var textContentLabel: UILabel!
    
    var imagesCollectionView: UICollectionView! /// A `UICollectionView` for displaying images of the memory.
    var gifView: GPHMediaView? /// A `GPHMediaView` for displaying gif of the memory.
    var audioView: AudioPlaybackView? /// An `AudioPlaybackView` for displaying audio of the memory.
    var images: [String]? { /// An array of image URLs. When set, the `imagesCollectionView` is reloaded.
        didSet {
            imagesCollectionView?.reloadData()
        }
    }
    
    // MARK: - View
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .systemCyan.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

    }
    
    /// Called to notify the view controller that its view is about to layout its subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    /// Returns the optimal size of the view considering the specified constraints.
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        size.height = max(size.height, 90)
        return size
    }
    
    /// Setup UI and layout for images collection view
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
    
    /// Configures the cell with the provided `Memory` object.
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
            gifView.layoutIfNeeded()
            self.gifView = gifView
        case .audio:
            let audioPlayer = AudioPlaybackView()
            guard let audioString = memory.audio else { return }
            
            let audioName = audioString.components(separatedBy: "/").last!
            let filename = ("\(audioName).m4a")
            
            if let cachedAudioURL = self.loadFileData(filename: filename) {
                // Use the local file URL to set the audioURL of the AudioPlaybackView
                audioPlayer.setAudioURL(cachedAudioURL)
            } else {
                // If the audio file is not found in local storage, download it from Firebase Storage
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentsDirectory = paths[0]
                let localURL = documentsDirectory.appendingPathComponent(filename)
                
                let storageRef = Storage.storage().reference(forURL: audioString)
                storageRef.write(toFile: localURL) { url, error in
                    if let error = error {
                        print("Error downloading audio: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            audioPlayer.setAudioURL(localURL)
                        }
                    }
                }
            }
            contentView.addSubview(audioPlayer)
            
            audioPlayer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                audioPlayer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                audioPlayer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                audioPlayer.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
                audioPlayer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            ])
            self.audioView = audioPlayer
        default:
            // Handle other memory types here
            break
        }
    }
    
    /// Loads the file data from the given filename.
    func loadFileData(filename: String) -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return fileURL
    }
    
    /// Hides all the controls. Called before configuring each cell to ensure only controls for that cell's memory type are displayed.
    func hideControls() {
        // hide all content views
        textContentLabel.isHidden = true
        imagesCollectionView?.removeFromSuperview()
        gifView?.removeFromSuperview()
        audioView?.removeFromSuperview()
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
