//
//  AppDelegate.swift
//  SpeechToTextDemo
//
//  Created by Subhra Roy on 26/02/19.
//  Copyright © 2019 ARC. All rights reserved.
//

import UIKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    public  let viewPageActivityType = "com.ARC.PrintApp"

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        INPreferences.requestSiriAuthorization { authorizationStatus  in
//            
//            switch authorizationStatus {
//                case .authorized:
//                    print("Authorized")
//                default:
//                    print("Not Authorized")
//            }
//            
//        }
        
       // INVocabulary.shared().setVocabularyStrings(["Track Id", "1001"], of: .notebookItemTitle)
        
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let intent = userActivity.interaction?.intent as? INSendMessageIntent else {
            print("AppDelegate: Start Send Message Intent - FALSE")
            return false
        }
        print("AppDelegate: Start Send Message Intent - TRUE")
        print("INTENT: ", intent)
        
        if userActivity.activityType == viewPageActivityType {
            print("open the `ViewController` here")
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let spokenPhrase : String = intent.content , spokenPhrase.count > 0 else {
                return false
            }
            
            let trackVC :  ARCTrackViewController = storyboard.instantiateViewController(withIdentifier: "ShowTrackIdentifier") as! ARCTrackViewController
            
            trackVC.setTrackDetails(track : spokenPhrase)
            
            self.window?.rootViewController = trackVC
            self.window?.makeKeyAndVisible()
            
            return true
        }
        
        return true
    }


}

