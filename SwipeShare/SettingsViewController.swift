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


class SettingsViewController: UITableViewController {

   
    
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    var delegate: LocationViewController? = nil

    

    
    @IBAction func movedSlider(sender: UISlider) {
        let currentValue = Int(sender.value)
        currentDistance.text = "\(currentValue) ft"
        
        delegate?.saveNewRadius(sender.value)
        print("Saved Radius?")
    }
    
        
    
    override func viewDidLoad() {
        print("Loaded settings view controller")
        super.viewDidLoad()
        
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
        userIcon.layer.borderWidth = 3
        userIcon.layer.masksToBounds = false
        userIcon.layer.borderColor = UIColor.grayColor().CGColor
        userIcon.layer.cornerRadius = userIcon.frame.height/2
        userIcon.clipsToBounds = true
        
        // Update name field with Facebook username taken from Parse
        usernameField.text = PFUser.currentUser()?["name"] as? String
        
    }
    
    @IBAction func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Initial") as! ViewController
            self.presentViewController(viewController, animated: true, completion: nil)
            
        })   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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