//
//  MemoryCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 3/5/2023.
//

import UIKit

class MemoryCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .systemCyan.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
    }
    
    func configure(memory: Memory) {
        titleLabel.text = memory.title
        descriptionLabel.text = memory.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        timeLabel.text = dateFormatter.string(from: memory.date)
    }
    
    
    
}
