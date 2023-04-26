//
//  DatabaseProtocol.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 26/4/2023.
//

import Firebase

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case team
    case heroes
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
//    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
//    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func signInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func signUpUser(email: String, password: String, name: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func signOutUser(completion: @escaping (Error?) -> Void)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
}

