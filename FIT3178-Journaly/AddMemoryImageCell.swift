//
//  AddMemoryImageCell.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 17/5/2023.
//

import UIKit

class AddMemoryImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let addLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .gray
        return label
    }()
    
    let plusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .gray
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false // important for constraints
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(deleteButton)
        addSubview(addLabel)
        addSubview(plusIcon)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),
            
            plusIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10), // 10 points above the center
            plusIcon.widthAnchor.constraint(equalToConstant: 20),
            plusIcon.heightAnchor.constraint(equalToConstant: 20),
            
            addLabel.topAnchor.constraint(equalTo: plusIcon.bottomAnchor, constant: 4),
            addLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            addLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
        ])
    }
    
}
