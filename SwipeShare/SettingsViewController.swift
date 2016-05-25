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
    let photoUtils = Utilities()
    var delegate: LocationViewController? = nil
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    var imagePicker: UIImagePickerController? = UIImagePickerController()
    
    // CoreData & Plist
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var currentUser: [User] = [User]()
    let user = PFUser.currentUser()
    let userDefaults = NSUserDefaults.standardUserDefaults()


    // Handle changes to range slider
    @IBAction func movedSlider(sender: UISlider) {
        let currentValue = Int(sender.value)
        currentDistance.text = "\(currentValue) ft"
        userDefaults.setInteger(currentValue, forKey: "distanceSlider")
        LocationViewController().saveNewRadius(sender.value)
    }
    
    // Handle switching between sharing settings (with friends vs. all)
    @IBOutlet weak var shareWithFriendsSwitch: UISwitch!
    @IBAction func shareWithFriendsSwitch(sender: AnyObject) {
        let sharingWithFriends = userDefaults.boolForKey("sharingWithFriends")
        userDefaults.setBool(!sharingWithFriends, forKey: "sharingWithFriends")
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
        
        navBar.title = "Settings"
        
        // Load defaults for settings
        shareWithFriendsSwitch.on = userDefaults.boolForKey("sharingWithFriends")
        distanceSlider.value = Float(userDefaults.integerForKey("distanceSlider"))
        let initialValue = Int(distanceSlider.value)
        currentDistance.text = "\(initialValue) ft"
        
        
        // Fetch the current user from CoreData, if the entity has been made
        let profilePictureFetch = NSFetchRequest(entityName: "User")
        let username = PFUser.currentUser()?["name"] as? String
        profilePictureFetch.predicate = NSPredicate(format: "%K == %@", "username", "currentUser")
        do {
            currentUser = try managedObjectContext.executeFetchRequest(profilePictureFetch) as! [User]
        } catch {
            fatalError("Failed to fetch current user: \(error)")
        }
        
        
        // Extract profile picture from parse, resize, and save to CoreData
        if (currentUser.isEmpty) {
            if let profilePicture = PFUser.currentUser()?["profilePicture"] as? PFFile {
                profilePicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        
                        // Resize and update view
                        self.userIcon.image = self.photoUtils.cropImageToSquare(image: UIImage(data: imageData!)!)
                        
                        // Create new CoreData User entity for current user
                        let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext)
                        let currentUserObject = User(username: "currentUser", displayName: username!, entity: userEntity!, insertIntoManagedObjectContext: self.managedObjectContext)
                        self.currentUser.append(currentUserObject)
                        
                        // Save image under current user
                        self.currentUser[0].profImageData = UIImageJPEGRepresentation(self.userIcon.image!, 1);
                    }
                }
            }
        }
        else {
            
            // Load the previous image from core data
            self.userIcon.image = UIImage(data: self.currentUser[0].profImageData!, scale: 1.0)
        }

        
        // Initialize gesture recognizer for changing profile pictures
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SettingsViewController.imageTapped(_:)))
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
        userIcon.image = self.photoUtils.cropImageToSquare(image: selectedImage!)
        
        // Update image in CoreData and Parse
        self.currentUser[0].profImageData = UIImageJPEGRepresentation(self.userIcon.image!, 1)
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

        if segue.identifier == "unwindToLogin" {
            print("Setting up lDelegate")
            print(delegate)
            let destination = segue.destinationViewController as! ViewController
            destination.delegate = delegate
        }
        
    }

}

