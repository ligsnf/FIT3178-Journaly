//
//  Memory.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 4/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

enum MemoryType: String {
    case text = "text"
    case images = "images"
    case video = "video"
    case audio = "audio"
    case gifs = "gifs"
}

class Memory: NSObject, Codable {
    
    // properties
    @DocumentID var id: String?
    var datetime: Date?
    var type: String?
    var title: String?
    var content: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case datetime
        case type
        case title
        case content
    }
}

extension Memory {
    var memoryType: MemoryType {
        get {
            return MemoryType(rawValue: self.type!)!
        }
        
        set {
            self.type = newValue.rawValue
        }
    }
}