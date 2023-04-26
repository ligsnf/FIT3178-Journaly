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
    
    // firebase references
    var authController: Auth
    var authStateHandle: AuthStateDidChangeListenerHandle?
    var database: Firestore
    var currentUser: FirebaseAuth.User?
    var userSnap: DocumentSnapshot?
    
    // MARK: - methods
    
    // constructor
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if user != nil {
                // user is signed in
                self.currentUser = user
                
                let userRef = self.database.collection("users").document(user!.uid)
                userRef.getDocument { (document, error) in
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
    
    // firestore
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
        
//        if listener.listenerType == .heroes || listener.listenerType == .all {
//            listener.onAllHeroesChange(change: .update, heroes: heroList)
//        }
//
//        if listener.listenerType == .team || listener.listenerType == .all {
//            listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes)
//        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }

}
