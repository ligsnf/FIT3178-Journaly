//
//  DatabaseProtocol.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import Firebase
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case memories
    case days
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onMemoriesChange(change: DatabaseChange, memories: [Memory])
    func onDaysChange(change: DatabaseChange, days: [Day])
}

protocol DatabaseProtocol: AnyObject {
    var userSnap: DocumentSnapshot? {get}
    
    func cleanup()
    
    // auth
    func signInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func signUpUser(email: String, password: String, name: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func signOutUser(completion: @escaping (Error?) -> Void)
    
    // listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func setupMemoriesListener()
    
    // date
    func setDate(_ date: Date)
    func getDate() -> Date
    
    // memories
    func addMemory(title: String, type: MemoryType, location: GeoPoint?, text: String?, images: [String]?, gif: String?, audio: String?) -> Memory
    func loadImageData(filename: String) -> UIImage?
    
}

