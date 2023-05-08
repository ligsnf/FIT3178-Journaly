//
//  MemoryCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 3/5/2023.
//

import UIKit

class MemoryCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
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
    
    func configure(memory: Memory) {
        titleLabel.text = memory.title
        contentLabel.text = memory.content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if let memoryDate = memory.datetime {
            timeLabel.text = dateFormatter.string(from: memoryDate)
        }
    }
    
    
    
}
