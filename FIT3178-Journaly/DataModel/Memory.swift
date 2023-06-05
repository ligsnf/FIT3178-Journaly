//
//  Memory.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 4/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MemoryType: String {
    case text = "text"
    case images = "images"
    case video = "video"
    case audio = "audio"
    case gif = "gif"
}

class Memory: NSObject, Codable {
    
    // properties
    @DocumentID var id: String?
    var datetime: Date?
    var location: GeoPoint? // for location of the memory
    var type: String?
    var title: String?
    var text: String?   // for text memories
    var images: [String]? // for image memories - array of image URLs
    var gif: String? // for GIF memories - the URL of the GIF
    
    enum CodingKeys: String, CodingKey {
        case id
        case datetime
        case location
        case type
        case title
        case text
        case images
        case gif
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
