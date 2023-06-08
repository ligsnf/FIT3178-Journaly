//
//  FirebaseController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

/// FirebaseController is the class responsible for managing the database functionalities of the application.
class FirebaseController: NSObject, DatabaseProtocol {  
    
    // MARK: - properties
    var listeners = MulticastDelegate<DatabaseListener>() // listeners for database changes
    var currentDate: Date = Date() // the current date for day view
    var dayList: [Day] // a list of Day objects of the current user
    var memories: [Memory] // a list of Memory objects of the current day
    
    // listener registrations for days and memories
    var daysListenerRegistration: ListenerRegistration?
    var memoriesListenerRegistration: ListenerRegistration?
    
    // firebase references
    var authController: Auth
    var authStateHandle: AuthStateDidChangeListenerHandle?
    var database: Firestore
    var currentUser: FirebaseAuth.User?
    var userSnap: DocumentSnapshot?
    var userRef: DocumentReference?
    var daysRef: CollectionReference?
    var memoriesRef: CollectionReference?
    
    // storage reference for Firebase Storage
    var storageReference = Storage.storage()
    
    // Lists for images and audios with their respective paths for caching
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var audioList = [URL]()
    var audioPathList = [String]()
    
    // MARK: - Methods
    
    // constructor
    override init() {
        authController = Auth.auth()
        database = Firestore.firestore()
        dayList = [Day]()
        memories = [Memory]()
        
        super.init()
        
        // Check authentication state
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            // If a user is signed in, set up a listener for user's days
            if user != nil {
                self.currentUser = user
                self.userRef = self.database.collection("users").document(user!.uid)
                
                self.setupDayListener()
                
                // Get the user document data
                self.userRef!.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.userSnap = document
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    /// Cleans up the listeners when the controller is about to stop using the database.
    func cleanup() {
        // remove listener when view controller is about to disappear
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }
    
    // This function sets the current date for the Day view
    func setDate(_ date: Date) {
        self.currentDate = date
    }
    
    // This function gets the current date for the Day view
    func getDate() -> Date {
        return self.currentDate
    }
    
    // This function formats a given date to a string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        // set date string for firestore id
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // This function handles the process of signing in a user using the provided email and password
    func signInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let _ = self else { return }
            if let error = error {
                print("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            self?.currentUser = authResult?.user
            print("Successfully signed in account with ID: \(authResult?.user.uid ?? "")")
            
            completion(authResult, error)
        }
    }
    
    // This function handles the process of creating a new user with the provided email, password and name
    func signUpUser(email: String, password: String, name: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Account creation failed: ", error.localizedDescription)
                return
            }
            self.currentUser = authResult?.user
            print("Successfully created account with ID: \(authResult?.user.uid ?? "")")
            
            // create user document
            self.addUser(for: authResult!.user, name: name) { error in
                if let error = error {
                    print("Error creating user document: \(error.localizedDescription)")
                } else {
                    // The user document was created successfully
                }
            }
            
            completion(authResult, error)
        }
    }
    
    // This function handles the process of signing out a user and cleaning up the related resources
    func signOutUser(completion: @escaping (Error?) -> Void) {
        do {
            try authController.signOut()
            // Remove the previous listener if it exists
            daysListenerRegistration?.remove()
            memoriesListenerRegistration?.remove()
            memories.removeAll() // Clear the memories array
            currentUser = nil
            print("Successfully signed out")
            completion(nil)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    // This function creates a new user document in Firestore for the signed up user
    func addUser(for user: User, name: String, completion: @escaping (Error?) -> Void) {
        let userRef = database.collection("users").document(user.uid)
        userRef.setData([
            "email": user.email ?? "",
            "name": name,
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    // MARK: Listeners
    
    // This function adds a DatabaseListener to the listeners list and triggers the respective listeners
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .days || listener.listenerType == .all {
            listener.onDaysChange(change: .update, days: dayList)
        }

        if listener.listenerType == .memories || listener.listenerType == .all {
            listener.onMemoriesChange(change: .update, memories: memories)
        }
        
    }
    
    // This function removes a DatabaseListener from the listeners list
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // This function creates a new memory document in Firestore and adds it to the memories array
    func addMemory(title: String, type: MemoryType, location: GeoPoint?, text: String?, images: [String]?, gif: String?, audio: String?) -> Memory {
        let memory = Memory()
        memory.title = title
        memory.type = type.rawValue
        memory.datetime = Date()
        
        if let memoryLocation = location {
            memory.location = memoryLocation
        }
        
        switch type {
        case .text:
            memory.text = text
        case .images:
            memory.images = images
        case .gif:
            memory.gif = gif
        case .audio:
            memory.audio = audio
        default:
            print("failed to add memory content: invalid memory type")
        }
        
        do {
            if let memoryRef = try memoriesRef?.addDocument(from: memory) {
                memory.id = memoryRef.documentID
            }
        } catch {
            print("Failed to serialize memory")
        }
        
        return memory
    }
    
    
    // This function loads image data from the device storage given the filename
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    
    // MARK: - Firebase Controller Specific Methods
    
    // This function sets up a Firestore listener for the days collection
    func setupDayListener() {
        // Remove the previous listener if it exists
        daysListenerRegistration?.remove()
        
        if let userRef = userRef {
            daysRef = userRef.collection("days")
            
            daysListenerRegistration = daysRef?.addSnapshotListener() {
                (querySnapshot, error) in
                guard let querySnapshot = querySnapshot else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                self.parseDaysSnapshot(snapshot: querySnapshot)
            }
        }
    }
    
    // This function sets up a Firestore listener for the memories sub-collection of the current day
    func setupMemoriesListener() {
        // Remove the previous listener if it exists
        memoriesListenerRegistration?.remove()
        memories.removeAll() // Clear the memories array

        if let daysRef = daysRef {
            memoriesRef = daysRef.document(formatDate(currentDate)).collection("memories")
            memoriesListenerRegistration = memoriesRef?.order(by: "datetime").addSnapshotListener { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot else {
                    print("Error fetching memories: \(String(describing: error))")
                    return
                }
                self.parseMemoriesSnapshot(snapshot: querySnapshot)
            }
        }
    }
    
    // This function parses a snapshot of the days collection and updates the local dayList array
    func parseDaysSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedDay: Day?
            do {
                parsedDay = try change.document.data(as: Day.self)
            } catch {
                print("Unable to decode day. Is the day malformed?")
                return
            }
            
            guard let day = parsedDay else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                dayList.insert(day, at: Int(change.newIndex))
            } else if change.type == .modified {
                dayList[Int(change.oldIndex)] = day
            } else if change.type == .removed {
                dayList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.days || listener.listenerType == ListenerType.all {
                listener.onDaysChange(change: .update, days: dayList)
            }
        }
    }
    
    // This function parses a snapshot of the memories sub-collection and updates the local memories array
    func parseMemoriesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedMemory: Memory?
            do {
                parsedMemory = try change.document.data(as: Memory.self)
            } catch {
                print("Unable to decode memory. Is the memory malformed?")
                return
            }
            
            guard let memory = parsedMemory else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                memories.insert(memory, at: Int(change.newIndex))
                
                switch memory.memoryType {
                case .images:
                    guard let imageURLs = memory.images else {
                        return
                    }
                    for imageURL in imageURLs {
                        let imageName = imageURL.components(separatedBy: "/").last!
                        let filename = ("\(imageName).jpg")
                        if !self.imagePathList.contains(filename) {
                            if let image = self.loadImageData(filename: filename) {
                                self.imageList.append(image)
                                self.imagePathList.append(filename)
                            } else {
                                // Next Step
                                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                let documentsDirectory = paths[0]
                                let fileURL = documentsDirectory.appendingPathComponent(filename)
                                let downloadTask = storageReference.reference(forURL: imageURL).write(toFile:fileURL)
                                
                                downloadTask.observe(.success) { snapshot in
                                    guard let image = self.loadImageData(filename: filename) else { return }
                                    self.imageList.append(image)
                                    self.imagePathList.append(filename)
                                }
                                
                                downloadTask.observe(.failure){ snapshot in
                                    print("\(String(describing: snapshot.error))")
                                }
                            }
                        }
                    }
                case .audio:
                    guard let audioURL = memory.audio else {
                            return
                        }
                        
                        let audioName = audioURL.components(separatedBy: "/").last!
                        let filename = ("\(audioName).m4a")
                        
                    if !self.audioPathList.contains(filename) {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let documentsDirectory = paths[0]
                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                        
                        let downloadTask = storageReference.reference(forURL: audioURL).write(toFile: fileURL)
                        
                        downloadTask.observe(.success) { snapshot in
                            self.audioList.append(fileURL)
                            self.audioPathList.append(filename)
                        }
                        
                        downloadTask.observe(.failure) { snapshot in
                            print("\(String(describing: snapshot.error))")
                        }
                    }
                default:
                    break
                }
            } else if change.type == .modified {
                memories[Int(change.oldIndex)] = memory
            } else if change.type == .removed {
                memories.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.memories || listener.listenerType == ListenerType.all {
                listener.onMemoriesChange(change: .update, memories: memories)
            }
        }
    }

}
