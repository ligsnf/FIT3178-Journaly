//
//  Memory.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 4/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Enum representing the various types of memories.
enum MemoryType: String {
    case text = "text"
    case images = "images"
    case video = "video"
    case audio = "audio"
    case gif = "gif"
}

/// `Memory` represents an individual memory within the journaling application.
/// A memory could be of different types (text, images, video, audio, gif) and has associated metadata such as
/// datetime and location. This class conforms to the `Codable` protocol, allowing for easy conversion to and
/// from JSON.
class Memory: NSObject, Codable {
    
    // properties
    @DocumentID var id: String?  // Unique identifier for the memory.
    var datetime: Date?  // Date and time when the memory was created.
    var location: GeoPoint?  // Geographical location where the memory was created.
    var type: String?  // Type of the memory (text, images, video, audio, gif).
    var title: String?  // Title of the memory.
    var text: String?   // Text content of the memory (for text memories).
    var images: [String]?  // URLs of images associated with the memory (for image memories).
    var gif: String?  // URL of the GIF associated with the memory (for GIF memories).
    var audio : String?  // Audio file associated with the memory (for audio memories).
    
    /// Coding keys used for encoding and decoding properties of a `Memory` object.
    enum CodingKeys: String, CodingKey {
        case id
        case datetime
        case location
        case type
        case title
        case text
        case images
        case gif
        case audio
    }
}

extension Memory {
    /// A computed property that provides access to the `MemoryType` associated with the memory.
    var memoryType: MemoryType {
        get {
            guard let type = self.type, let memoryType = MemoryType(rawValue: type) else {
                // Add default case here. Here it is set to .text, modify as per your needs.
                return .text
            }
            return memoryType
        }
        
        set {
            self.type = newValue.rawValue
        }
    }
}
