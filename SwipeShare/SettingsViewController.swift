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
    
    @IBAction func getFacebookFriends(sender: AnyObject) {
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "friends, picture"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil)
            {
                let resultDict = result as! NSDictionary
                print("result \(resultDict)")
                
//                let data : NSArray = resultDict.objectForKey("data") as! NSArray
//
//                for i in data {
//                    let valueDict : NSDictionary = i as! NSDictionary
//                    print("valueDict = \(valueDict)")
//                    
//                    let id = valueDict.objectForKey("id") as! String
//                    print("the id value is \(id)")
//                }
                
            }
            else
            {
                print("error \(error)")
            }
        })
        return
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(30)] as Dictionary!
        navBar.leftBarButtonItem!.setTitleTextAttributes(attributes, forState: .Normal)
        navBar.leftBarButtonItem!.title = String.ioniconWithName(.Home)
        
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

        }
        else if (indexPath.section == 2) {
            logout()
        }
        
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
            print("Setting up lDelegate")
            print(delegate)
            let destination = segue.destinationViewController as! ViewController
            destination.delegate = delegate
        }
    }
}

