//
//  AppDelegate.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 03/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        DBWrapper.sharedObj.createTable()
        GMSPlacesClient.provideAPIKey("AIzaSyAjBFwLFydP_CGHU3w_9tNSDScqeSu5UyQ")//("AIzaSyAjBFwLFydP_CGHU3w_9tNSDScqeSu5UyQ")
        GMSServices.provideAPIKey("AIzaSyAjBFwLFydP_CGHU3w_9tNSDScqeSu5UyQ")//("AIzaSyDf3W8h-V5lAHoFEnd09aWOJsrqe5q3HCk")
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

