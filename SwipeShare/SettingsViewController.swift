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

import FBSDKCoreKit
import ParseFacebookUtilsV4


class SettingsViewController: UITableViewController {
   
    
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    var delegate: LocationViewController? = nil
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let userDefaults = NSUserDefaults.standardUserDefaults()


    
    @IBAction func movedSlider(sender: UISlider) {
        let currentValue = Int(sender.value)
        currentDistance.text = "\(currentValue) ft"
        userDefaults.setInteger(currentValue, forKey: "distanceSlider")
        LocationViewController().saveNewRadius(sender.value)
    }
    
    @IBOutlet weak var shareWithFriendsSwitch: UISwitch!
    
    @IBAction func shareWithFriendsSwitch(sender: AnyObject) {
        let sharingWithFriends = userDefaults.boolForKey("sharingWithFriends")
        userDefaults.setBool(!sharingWithFriends, forKey: "sharingWithFriends")
    }
        
    @IBAction func exitButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueHome", sender: self)
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
        
        shareWithFriendsSwitch.on = userDefaults.boolForKey("sharingWithFriends")
        
        distanceSlider.value = Float(userDefaults.integerForKey("distanceSlider"))
        
        let initialValue = Int(distanceSlider.value)
        currentDistance.text = "\(initialValue) ft"
        
        // Extract profile picture from parse and resize
        if let profilePicture = PFUser.currentUser()?["profilePicture"] as? PFFile {
            profilePicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.userIcon.image = self.cropImageToSquare(image: UIImage(data: imageData!)!)
                }
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        userIcon.userInteractionEnabled = true
        userIcon.addGestureRecognizer(tapGestureRecognizer)
        
        
        userIcon.layer.borderWidth = 3
        userIcon.layer.masksToBounds = false
        userIcon.layer.borderColor = UIColor.grayColor().CGColor
        userIcon.layer.cornerRadius = userIcon.frame.height/2
        userIcon.clipsToBounds = true
        
        // Update name field with Facebook username taken from Parse
        usernameField.text = PFUser.currentUser()?["name"] as? String
        
    }
    
    func imageTapped(img: AnyObject) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Initial") as! ViewController
            self.presentViewController(viewController, animated: true, completion: nil)
            
        })
    }
    
    
    func cropImageToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image

    }
    
}