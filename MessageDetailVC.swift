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
    
    // For handling add/block of users
    let messageManager = MessageManager.sharedMessageManager
    var fetchedFriends = [Friend]()
    var blockingUser = false
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
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
        
        
        // Fetch friends for referencing when giving prompt 
        let friendFetchRequest = NSFetchRequest(entityName: "Friend")
        
        do {
            fetchedFriends = try managedContext.executeFetchRequest(friendFetchRequest) as! [Friend]
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
        messageNavBar.title = String(message.sender["name"])
        let date = NSDateFormatter.localizedStringFromDate(message.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        dateLabel.title = date
        
        
        // Prompt the user for input if the message is from a non-Friend user
        if !isFriend(message.sender.username!){
            
            let friendPromptViewController = storyboard!.instantiateViewControllerWithIdentifier("friendprompt") as! FriendPromptViewController
            friendPromptViewController.delegate = self
            friendPromptViewController.modalPresentationStyle = .OverCurrentContext
            presentViewController(friendPromptViewController, animated: true, completion: nil)
           
        }
        else if message.image == nil {
            getPhoto()
        }
        else {
            
            self.activityIndicator.stopAnimating()
        }
        messageImageView?.image = message.image
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.toolbarHidden = true
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.hidesBarsOnTap = false
    }
    
    func getPhoto(){
        let query = PFQuery(className: "sentPicture")
        query.getObjectInBackgroundWithId(self.message.id){
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                
                if let picture = object!["image"] as? PFFile {
                    
                    picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            print("Photo downloaded")
                            self.message.image = UIImage(data:imageData!)
                            self.messageImageView.image = self.message.image
                            self.activityIndicator.stopAnimating()
                            // Set object to read.
                            object!["hasBeenRead"] = true
                            object!.saveInBackground()
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


    // Called when a message is received from a new user to save friend to CoreData
    func saveFriend() {
        
        // Save to CoreData
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: managedObjectContext)
        let friend = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
        friend.setValue(message.sender.username, forKey: "username")
        
        do {
            try managedObjectContext.save()
            print("successfully saved friend")
        } catch let error {
            print("error saving new friend in managedObjectContext: \(error)")
        }
        
        getPhoto()
    }

    // Called when user decides to block another user
    // Saves a corresponding BlockedUser entity to CoreData
    func blockUser() {
        
        blockingUser = true
        
        // Save to CoreData
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("BlockedUser", inManagedObjectContext: managedObjectContext)
        let blockedUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
        blockedUser.setValue(message.sender.username, forKey: "username")
        
        do {
            try managedObjectContext.save()
            print("successfully blocked user")
        } catch let error {
            print("error blocking user in managedObjectContext: \(error)")
        }
        
        // Once migration to core data is complete, this method needs to be implemented in MessageTableVC
//        delegate?.removeBlockedUserMessages()
    }

    // Check to see if the user is a friend
    func isFriend(username: String) -> Bool {
        
        for friend in fetchedFriends {
            print(friend.username)
            if friend.username == username {
                return true
            }
        }
        return false
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
