//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by norah alshareef on 10/07/2019.
//  Copyright © 2019 norah alshareef. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        DataController.sharedDataController.load()
        // Override point for customization after application launch.
        return true
    }

  
    func applicationDidEnterBackground(_ application: UIApplication) {
       saveViewContext()
    }

  
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    func saveViewContext(){
        try? DataController.sharedDataController.viewContext.save()
    }


}

