//
//  AppDelegate.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/11/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Localize

import IQKeyboardManagerSwift

var googleApiKey = "AIzaSyCWidFreZJDiR5SNB-d9MW3fdVzoqerh2g"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func reset() {
        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let stry = UIStoryboard(name: "Main", bundle: nil)
        rootviewcontroller.rootViewController = stry.instantiateViewController(withIdentifier: "rootnav")
        print("traaaa")
      
    }
    

    var window: UIWindow?
    var kuserDef = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//        let localize = Localize.shared
//        // Set your localize provider.
//        localize.update(provider: .strings)
//        // Set your file name
//        localize.update(fileName: "Main")
//        // Set your default languaje.
//        localize.update(defaultLanguage: "es-ES")
//        // If you want change a user language, different to default in phone use thimethod.
//        localize.update(language: "en")
//        // If you want remove storaged languaje use
//       // localize.resetLanguage()
//        // The used language
//        print(localize.currentLanguage)
//        // List of aviable languajes
//        print(localize.availableLanguages)
//
        // Or you can use static methods for all
//        
//        Localize.update(fileName: "es-ES")
//        Localize.update(defaultLanguage: "en")
//        Localize.update(language: "es-ES")
        let user2 = ["userFirstName": "Fname", "userSecondName": "lname", "space": false] as [String : Any]
        kuserDef.set(user2, forKey: "user")
        kuserDef.synchronize()
        ReachabilityManager.shared.startMonitoring()
        FirebaseApp.configure()

          L102Localizer.DoTheMagic();
        let db = Firestore.firestore()
//        GMSServices.provideAPIKey("AIzaSyAObdd0ZhiTt1ukFWYabfgCwCcfguL94oI")
//        GMSPlacesClient.provideAPIKey("AIzaSyAObdd0ZhiTt1ukFWYabfgCwCcfguL94oI")
        
        GMSServices.provideAPIKey("AIzaSyCWidFreZJDiR5SNB-d9MW3fdVzoqerh2g")
        GMSPlacesClient.provideAPIKey("AIzaSyCWidFreZJDiR5SNB-d9MW3fdVzoqerh2g")
        IQKeyboardManager.shared.enable = true
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
         ReachabilityManager.shared.stopMonitoring()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
          ReachabilityManager.shared.startMonitoring()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

