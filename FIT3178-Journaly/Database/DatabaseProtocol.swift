//
//  DatabaseProtocol.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import Firebase
import UIKit

/// Enum representing the types of changes that can be made in the database.
enum DatabaseChange {
    case add
    case remove
    case update
}

/// Enum representing the types of listeners that can be set up for observing database changes.
enum ListenerType {
    case memories
    case days
    case all
}

/// A protocol that defines the requirements for an object to act as a database listener.
protocol DatabaseListener: AnyObject {
    
    /// Defines the type of the listener.
    var listenerType: ListenerType {get set}
    
    /// Called when there are changes in the memories collection.
    /// - Parameters:
    ///   - change: The type of change.
    ///   - memories: The updated set of memories.
    func onMemoriesChange(change: DatabaseChange, memories: [Memory])
    
    /// Called when there are changes in the days collection.
    /// - Parameters:
    ///   - change: The type of change.
    ///   - days: The updated set of days.
    func onDaysChange(change: DatabaseChange, days: [Day])
}

/// A protocol that defines the requirements for the database functionality of the application.
protocol DatabaseProtocol: AnyObject {
    /// The document snapshot of the current user.
    var userSnap: DocumentSnapshot? {get}
    
    /// Cleans up the listeners when the application is about to stop using the database.
    func cleanup()
    
    // MARK: Authentication
    /// Sign in an existing user.
    func signInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    /// Sign up a new user.
    func signUpUser(email: String, password: String, name: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    /// Sign out the currently logged in user.
    func signOutUser(completion: @escaping (Error?) -> Void)
    
    // MARK: Listeners
    /// Add a listener to the database.
    func addListener(listener: DatabaseListener)
    /// Remove a listener from the database.
    func removeListener(listener: DatabaseListener)
    /// Set up a listener for the memories collection.
    func setupMemoriesListener()
    
    // MARK: Date
    /// Set the current date.
    func setDate(_ date: Date)
    /// Get the current date.
    func getDate() -> Date
    
    // MARK: Memories
    /// Add a memory to the memories collection.
    func addMemory(title: String, type: MemoryType, location: GeoPoint?, text: String?, images: [String]?, gif: String?, audio: String?) -> Memory
    /// Load an image from the local file system.
    func loadImageData(filename: String) -> UIImage?
    
}

