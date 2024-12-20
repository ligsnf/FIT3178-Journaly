//
//  AppDelegate.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 24/4/2023.
//

import UIKit
import Firebase
import GiphyUISDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var databaseController: DatabaseProtocol?
    var loginNavigationController: UINavigationController?
    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // initialise firebase controller
        FirebaseApp.configure()
        databaseController = FirebaseController()
        
        // configure GIPHY API key
        Giphy.configure(apiKey: "YE7737hrCcMfrjZxGXIcnxBMVLe3l1oe")
        
        // initialise navigation controllers
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController else {
            fatalError("Could not instantiate loginNavigationController")
        }
        self.loginNavigationController = loginNavigationController
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            fatalError("Could not instantiate TabBarController")
        }
        self.tabBarController = tabBarController
        
        // style navigation bar appearance
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.prefersLargeTitles = true
        
        // launch success
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

