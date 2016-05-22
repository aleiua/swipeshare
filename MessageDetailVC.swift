//
//  MessageDetailVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/6/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

import UIKit
import Parse
import CoreData

class MessageDetailVC: UIViewController, UIScrollViewDelegate{
    
    var delegate: MessageTableVC? = nil
    var message: Message!
    var comingFrom: String!
    
    // For handling add/block of users
    //let messageManager = MessageManager.sharedMessageManager
    var blockedUsers = [User]()
    var fetchedFriends = [User]()
    var blockingUser = false
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var dateLabel: UIBarButtonItem!
    
    @IBOutlet weak var messageNavBar: UINavigationItem!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction func savePhoto(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(messageImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return self.imageView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        
        // Fetch blocked users for referencing when giving prompt (Previously located in Message Table VC)
        let blockedUserFetchRequest = NSFetchRequest(entityName: "User")
        // Create Predicate
        let blockedPredicate = NSPredicate(format: "%K == %@", "status", "blocked")
        blockedUserFetchRequest.predicate = blockedPredicate
        
        do {
            blockedUsers = try managedObjectContext.executeFetchRequest(blockedUserFetchRequest) as! [User]
            print("going to print blocked users count")
            print(blockedUsers.count)
        } catch {
            print("error fetching blocked user list from CoreData")
        }
        
        
        // Fetch friends for referencing when giving prompt
        let friendFetchRequest = NSFetchRequest(entityName: "User")
        // Create Predicate
        let friendPredicate = NSPredicate(format: "%K == %@", "status", "friend")
        blockedUserFetchRequest.predicate = friendPredicate
        do {
            fetchedFriends = try managedObjectContext.executeFetchRequest(friendFetchRequest) as! [User]
            print("going to print friend count")
            print(fetchedFriends.count)
        } catch {
            print("error fetching friend list from CoreData")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = false
        self.navigationController!.hidesBarsOnTap = true
        
        let date = NSDateFormatter.localizedStringFromDate(message.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)

        
        if comingFrom == "MessageTableVC" {
        
            messageNavBar.title = String(message.user.displayName)
            
        } else {
    
            messageNavBar.title = date
            
        }
            
            
        // Prompt the user for input if the message is from a non-Friend user
        if (message.user.status != "friend" && message.allowedOnce == false) {
            
            let friendPromptViewController = storyboard!.instantiateViewControllerWithIdentifier("friendprompt") as! FriendPromptViewController
            friendPromptViewController.delegate = self
            friendPromptViewController.sender = message.user
            friendPromptViewController.modalPresentationStyle = .OverCurrentContext
            presentViewController(friendPromptViewController, animated: true, completion: nil)
            
        }
        else {
            photoAppear()
        }
    }
    
    func photoAppear() {
        if message.imageData == nil{
            getPhoto()
        } else {
            self.activityIndicator.stopAnimating()
            messageImageView?.image = UIImage(data: message.imageData!)
        }
    }
    
    func updateAllowOnce() {
        self.message.allowedOnce = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.toolbarHidden = true
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.hidesBarsOnTap = false
    }
    
    func getPhoto(){
        let query = PFQuery(className: "sentPicture")
        query.getObjectInBackgroundWithId(self.message.objectId){
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                
                if let picture = object!["image"] as? PFFile {
                    
                    picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            print("Photo downloaded")
                            self.message.imageData = imageData
                            
                            let currentInstallation = PFInstallation.currentInstallation()
                            if currentInstallation.badge != 0 && self.message.hasBeenOpened == false {
                                currentInstallation.badge -= 1
                                currentInstallation.saveEventually()
                            }
                            
                            self.message.hasBeenOpened = true
                            self.messageImageView.image = UIImage(data: self.message.imageData!)
                            self.activityIndicator.stopAnimating()
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                fatalError("Failure to save context: \(error)")
                            }
                            
                            
                            
                        }
                        else {
                            print("Error getting image data")
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
                
            }
            else {
                print(error)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "The image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "sendAgainSegue" {
            
            let destinationViewController = segue.destinationViewController as! LocationViewController
            
            destinationViewController.image = messageImageView
            
            
        }
    }

    
    // Update user status
    func updateUserStatus(status: String) {
        message.user.status = status
        
        if status == "blocked" {
            blockingUser = true
            // Delete messages from core data
        }
        
        do {
            try managedObjectContext.save()
            print("successfully saved user")
        } catch let error {
                print("error saving new friend in managedObjectContext: \(error)")
        }

        
    }


//    // Called when a message is received from a new user to save friend to CoreData
//    func saveFriend() {
//        
//        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: managedObjectContext)
//        let friend = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
//        friend.setValue(message.sender, forKey: "username")
//        
//      //
//        getPhoto()
//    }
//    
//
//    // Called when user decides to block another user
//    // Saves a corresponding BlockedUser entity to CoreData
//    func blockUser() {
//        
//        blockingUser = true
//        
//        // Save to CoreData
//        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//        let entity = NSEntityDescription.entityForName("BlockedUser", inManagedObjectContext: managedObjectContext)
//        let blockedUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
//        blockedUser.setValue(message.sender, forKey: "username")
//        
//        do {
//            try managedObjectContext.save()
//            print("successfully blocked user")
//        } catch let error {
//            print("error blocking user in managedObjectContext: \(error)")
//        }
//        
//        // Once migration to core data is complete, this method needs to be implemented in MessageTableVC
////        delegate?.removeBlockedUserMessages()
//    }

    // Check to see if the user is a friend
    func isFriend(user: User) -> Bool {
        
        for friend in fetchedFriends {
            print(friend.username)
            if friend.username == user.username {
                return true
            }
        }
        return false
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
