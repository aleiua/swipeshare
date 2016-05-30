//
//  SettingsViewController.swift
//  SwipeShare
//
//  Created by Troy Palmer on 3/4/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData
import FBSDKCoreKit
import ParseFacebookUtilsV4


class SettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    // Delegate & Utilities
    let utils = Utilities()
    var delegate: LocationViewController? = nil
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    var imagePicker: UIImagePickerController? = UIImagePickerController()
    
    
    var facebookFriends = [String]()

    
    
    // Current user profile for settings & profile picture
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var currentUserProfileArray: [CurrentUserProfile] = [CurrentUserProfile]()
    let user = PFUser.currentUser()


    // Handle changes to range slider
    @IBAction func movedSlider(sender: UISlider) {
        let currentValue = Int(sender.value)
        currentDistance.text = "\(currentValue) ft"
        currentUserProfileArray[0].maxDistanceSetting = Float(currentValue)
        LocationViewController().saveNewRadius(sender.value)
    }
    
    // Handle switching between sharing settings (with friends vs. all)
    @IBOutlet weak var shareWithFriendsSwitch: UISwitch!
    @IBAction func shareWithFriendsSwitch(sender: AnyObject) {
        currentUserProfileArray[0].shareWithFriendsSetting = !currentUserProfileArray[0].shareWithFriendsSetting
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupFriends()
        
        // Fetch the current user from CoreData, if the entity has been made
        let userProfileFetch = NSFetchRequest(entityName: "CurrentUserProfile")
        userProfileFetch.predicate = NSPredicate(format: "%K == %@", "username", PFUser.currentUser()!.username!)
        do {
            currentUserProfileArray = try managedObjectContext.executeFetchRequest(userProfileFetch) as! [CurrentUserProfile]
        } catch {
            fatalError("Failed to fetch current user: \(error)")
        }
        if (self.currentUserProfileArray.endIndex > 1 || self.currentUserProfileArray.isEmpty) {
            fatalError("failed to load user profile")
        }
        
        
        // Extract profile picture from parse, resize, and save to CoreData if the local one isnt set already
        if (self.currentUserProfileArray[0].profImageData == nil) {
            if let profilePicture = PFUser.currentUser()?["profilePicture"] as? PFFile {
                profilePicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        
                        // Resize and update view
                        self.userIcon.image = self.utils.cropImageToSquare(image: UIImage(data: imageData!)!)
                        
                        // Update the user profile with the image
                        self.currentUserProfileArray[0].profImageData = UIImageJPEGRepresentation(self.userIcon.image!, 1);

                    }
                }
            }
            // If the user doesn't have one in parse, use a default image
            else {
                print("need to assign default profile picture")
            }
        }
        // If there already is a local image, load it
        else {
            self.userIcon.image = UIImage(data: self.currentUserProfileArray[0].profImageData!, scale: 1.0)
        }

        
        
        // Load defaults for settings
        navBar.title = "Settings"
        shareWithFriendsSwitch.on = currentUserProfileArray[0].shareWithFriendsSetting
        distanceSlider.value = Float(currentUserProfileArray[0].maxDistanceSetting)
        let initialValue = Int(distanceSlider.value)
        currentDistance.text = "\(initialValue) ft"
        
        // Initialize gesture recognizer for changing profile pictures
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        userIcon.userInteractionEnabled = true
        userIcon.addGestureRecognizer(tapGestureRecognizer)
        
        // Aesthetics for userIcon
        userIcon.layer.borderWidth = 2
        userIcon.layer.masksToBounds = false
        userIcon.layer.borderColor = UIColor.lightGrayColor().CGColor
        userIcon.layer.cornerRadius = userIcon.frame.height/2
        userIcon.clipsToBounds = true
        
        // Update name field with Facebook username taken from Parse
        usernameField.text = PFUser.currentUser()?["name"] as? String
    }
    
    
    /*
    * Called when the profile picture is tapped; presents the image picker view controller
    */
    func imageTapped(img: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker!.allowsEditing = false
            
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
        
        
    }
    
    /*
    *  Updates the profile picture in the view with the selected image and updates CoreData and Parse
    */
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // Get image from image picker and update view
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        userIcon.image = self.utils.cropImageToSquare(image: selectedImage!)
        
        // Update image in CoreData and Parse
        self.currentUserProfileArray[0].profImageData = UIImageJPEGRepresentation(self.userIcon.image!, 1)
        saveProfPicToParse(userIcon.image!)
    }
    
    
    /*
     * Update the profile picture of the current user (global) with the given UIImage
     */
    func saveProfPicToParse(image: UIImage) {
        
        let filename = "image.jpg"
        let jpgImage = UIImageJPEGRepresentation(image, 0.5)
        let imageFile = PFFile(name: filename, data: jpgImage!)
        
        user!["profilePicture"] = imageFile
        user?.saveInBackground()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row: \(indexPath.row)")
        print("Section: \(indexPath.section)")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        
        if (indexPath.section == 0) {
            // Friends and Distance
        }
        else if (indexPath.section == 1) {
            // Will be segues to friend functionality
            if (indexPath.row == 0) {
                performSegueWithIdentifier("toFriendTable", sender: nil)
            }
            else if (indexPath.row == 1) {
                
                performSegueWithIdentifier("toAddFriends", sender: nil)
            }

        }
        else if (indexPath.section == 2) {
            logout()
        }
        
    }
    
    
    
    
    
    func setupFriends() {
        let yawFriends = getFriendList()
        findFacebookFriends(yawFriends)
    }
    
    func findFacebookFriends(yawFriends : Set<String>) {

        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"friends"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil)
            {
                
                let resultDictionary = result as! NSDictionary
                let friendDictionary = resultDictionary.objectForKey("friends") as! NSDictionary
                let data = friendDictionary.objectForKey("data") as! NSArray
                
                
                for item in data {
                    let itemDict = item as! NSDictionary
                    let friendName = itemDict.objectForKey("name") as! String
                    // Check to make sure aren't already friends.
                    if (!yawFriends.contains(friendName)) {
                        self.facebookFriends.append(friendName)
                    }
                }
                print("FacebookFriends:")
                print(self.facebookFriends)
                
            }
            else
            {
                print("error \(error)")
            }
        })
    }
    
    func getFriendList() ->  Set<String>{
        
        
        var yawFriends = Set<String>()

        // Fetch list of blocked users by username from CoreData
        let friendFetchRequest = NSFetchRequest(entityName: "User")
        // Create Predicate
        let friendPredicate = NSPredicate(format: "%K == %@", "status", "friend")
        friendFetchRequest.predicate = friendPredicate
        do {
            let friends = try managedObjectContext.executeFetchRequest(friendFetchRequest) as! [User]
            for friend in friends {
                yawFriends.insert(friend.displayName)
            }
        } catch {
            print("error fetching list of blocked users")
        }
        
        return yawFriends
        
    }

    
    func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        print("Logout")
    

        self.performSegueWithIdentifier("unwindToLogin", sender: self)

        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        if segue.identifier == "unwindToLogin" {
            print(delegate)
            let destination = segue.destinationViewController as! ViewController
            destination.delegate = delegate
        }
        else if segue.identifier == "toAddFriends" {
            let destination = segue.destinationViewController as! AddFriendsViewController
            destination.facebookFriends = self.facebookFriends
            
        }
    }
}

