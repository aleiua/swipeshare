//
//  AppDelegate.swift
//  SwipeShare
//
//  Created by A. Lynn on 1/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import CoreData
import Parse
import Bolts
import LocationKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        //Connect to Parse
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("Gsr2KOBej8uVGrhLE7uzbhqrihagNICRk51VDaBj",
            clientKey: "rFScD5ejwXbR0CcI5AP91ijYRNV1JY2qhWvFMkl2")
        
        // Initialize Facebook Notifications
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        
        // Register Push Notifications
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        
        // Set Up Location Kit Manager
        let locationManager = LKLocationManager()
        // The debug flag is not necessary (and should not be enabled in prod)
        // but does help to ensure things are working correctly
        locationManager.debug = false
        locationManager.apiToken = "76f847c677f70038"
        locationManager.startUpdatingLocation()
        // if there's a notification with a photo
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            
            // Create a pointer to the Photo object
            let photoId = notificationPayload["p"] as? String
            getMessage(photoId!)
            let detailViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("detailVC") as! MessageDetailVC
//            detailViewController.message = 
            
            // Fetch messages from core Data, sorted by date
            let messageFetchRequest = NSFetchRequest(entityName: "Message")
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) // Puts newest messages on top
            messageFetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                fetchedMessage = try managedContext.executeFetchRequest(messageFetchRequest) as! [Message]
            } catch {
                fatalError("Failed to fetch messages: \(error)")
            }

            let navController = window?.rootViewController?.navigationController
                navController!.pushViewController(detailViewController, animated: true)
        }
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        return true
    }
    
    func getMessage(id: String) -> Message? {
        let query = PFQuery(className:"sentPicture")
        query.getObjectInBackgroundWithId(id) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                
                let messageSender = object!["sender"] as! PFUser
                let sender: User
                
                // Check if sender exists in local User storage
                let checkForSenderFetchRequest = NSFetchRequest(entityName: "User")
                let predicate = NSPredicate(format: "%K == %@", "username", messageSender["username"] as! String)
                checkForSenderFetchRequest.predicate = predicate
                
                // Execute Fetch Request to check if User exists locally
                do {
                    let users = try self.managedObjectContext.executeFetchRequest(checkForSenderFetchRequest)
                    
                    // If the user does exist locally - set Store User to the local user entity for updating purposes
                    if users.count != 0 {
                        sender = users[0] as! User
                        print("sender already stored")
                        
                    } else {        // Create a new User entity to store
                        print("creating new sender")
                        let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext)
                        sender = User(username: messageSender["username"] as! String, displayName: messageSender["name"] as! String, entity: userEntity!, insertIntoManagedObjectContext: self.managedObjectContext)
                    }
                    
                    // If sender is a blocked user - do not save or display incoming message
                    if sender.status == "blocked" {
                        abort()
                    }
                    
                    // Create message object
                    let messageId = object!.objectId
                    let sentDate = object!.createdAt! as NSDate
                    let entityDescripition = NSEntityDescription.entityForName("Message", inManagedObjectContext: self.managedObjectContext)
                    let message = Message(date: sentDate, imageData: nil, objectId: messageId!, entity: entityDescripition!, insertIntoManagedObjectContext: self.managedObjectContext)
                    
                    // Set up relationship between message and sender in core data
                    message.user = sender
                    
                    sender.mutableSetValueForKey("messages").addObject(message)
                    
                    // update sender most recent communication date
                    sender.mostRecentCommunication = sentDate
                    
                    // Set message object to read on parse - which means it has been downloaded to phone
                    object!["hasBeenRead"] = true
                    object!.saveInBackground()
                    
                } catch {   // Catch any errors fetching from Core Data
                    let fetchError = error as NSError
                    print(fetchError)
                }
                
                // SAVING MANAGED OBJECT CONTEXT - SAVES MESSAGES TO CORE DATA
                do {
                    try self.managedObjectContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            } else {
                print(error)
            }
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    
    
    
    
    // Registered push notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    // Receive Push notifications
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

//    func applicationDidBecomeActive(application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        FBSDKAppEvents.activateApp()
//        let currentInstallation = PFInstallation.currentInstallation()
//        if currentInstallation.badge != 0 {
//            currentInstallation.badge = 0
//            currentInstallation.saveEventually()
//        }
//    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yaw.SwipeShare" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SwipeShare", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

