//
//  FirebaseController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {  
    
    // MARK: - properties
    var listeners = MulticastDelegate<DatabaseListener>()
    var currentDate: Date = Date()
    var dayList: [Day]
    var memories: [Memory]
    
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
    
    // MARK: - methods
    
    // constructor
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        dayList = [Day]()
        memories = [Memory]()
        
        super.init()
        
        // Check auth
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if user != nil {
                // user is signed in
                self.currentUser = user
                self.userRef = self.database.collection("users").document(user!.uid)
                
                self.setupDayListener() // set up listener for user's days
                
                self.userRef!.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.userSnap = document
//                        print("Document data: \(document)")
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    func cleanup() {
        // remove listener when view controller is about to disappear
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }
    
    // set the current date for day view
    func setDate(_ date: Date) {
        self.currentDate = date
    }
    
    // get the current date for day view
    func getDate() -> Date {
        return self.currentDate
    }
    
    // get current date as formatted string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        // set date string for firestore id
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // authentication
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
    
    func signOutUser(completion: @escaping (Error?) -> Void) {
        do {
            try authController.signOut()
            currentUser = nil
            completion(nil)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    // create user in firestore
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
    
    
    // listeners
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .days || listener.listenerType == .all {
            listener.onDaysChange(change: .update, days: dayList)
        }

        if listener.listenerType == .memories || listener.listenerType == .all {
            listener.onMemoriesChange(change: .update, memories: memories)
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Firebase Controller Specific Methods
    func setupDayListener() {
        if let userRef = userRef {
            daysRef = userRef.collection("days")
            
            daysRef?.addSnapshotListener() {
                (querySnapshot, error) in
                guard let querySnapshot = querySnapshot else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                self.parseDaysSnapshot(snapshot: querySnapshot)
            }
        }
    }
    
    
    func setupMemoriesListener() {
        // Remove the previous listener if it exists
        memoriesListenerRegistration?.remove()

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
    
    func parseMemoriesSnapshot(snapshot: QuerySnapshot) {
        memories.removeAll() // Clear the memories array
        
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
