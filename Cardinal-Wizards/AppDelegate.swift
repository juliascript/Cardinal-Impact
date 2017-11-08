//
//  AppDelegate.swift
//  Cardinal-Wizards
//
//  Created by Julia Geist on 10/3/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import UIKit
import Firebase
import Cache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentUser: User?
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            Helper.decacheUser()
            FirebaseApp.configure()
            
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            
            if launchedBefore  {
                print("Not first launch.")
                
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        if let userInfo = self.loadUserInfo() {
                            print("User info collected from cache: \(userInfo)")
                            self.currentUser = userInfo
                            self.loginUser()
                            return
                        } else {
                            let fb = FirebaseHelper()
                            
                            fb.retrieveUser(uid: user.uid, callback: { (retrievedUser) in
                                
                                self.currentUser = retrievedUser
                                self.loginUser()
                                return
                            })
                        }
                    }
                    self.getInitialView(withIdentifier: "Login")
                }
            } else {
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                getInitialView(withIdentifier: "Login")
            }
            
            return true
        }
        
        func loginUser() {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! MapViewController
            
            vc.currentUser = self.currentUser!
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        func getInitialView(withIdentifier: String)  {
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "LoginFlow", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: withIdentifier) as UIViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        func loadUserInfo() -> User? {
            let diskConfig = DiskConfig(name: "Floppy")
            
            let storage = try? Storage(diskConfig: diskConfig)
            
            // Check if an object exists
            let hasUser = try? storage!.existsObject(ofType: User.self, forKey: "currentUser")
            
            if hasUser! {
                let currentUser = try? storage!.object(ofType: User.self, forKey: "currentUser")
                return currentUser
            }
            return nil
            
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


}

