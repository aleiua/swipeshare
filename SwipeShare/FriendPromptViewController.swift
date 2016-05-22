//
//  CheckListViewController.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 4/7/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class FriendPromptViewController: UIViewController {
    var delegate: MessageDetailVC? = nil
    var sender: User? = nil
    
    @IBOutlet weak var blurredBackgroundView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var allowOnceButton: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var newUserPicture: UIImageView!
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEditing(true, animated: true)
        
        if sender?.profImageData != nil {
            let imageRepresenation = UIImage(data : sender!.profImageData!)
            
            let settingsController = SettingsViewController()
            let squareImage = settingsController.cropImageToSquare(image: imageRepresenation!)

            newUserPicture.image = squareImage
        }
        
        

        
        newUserPicture.layer.borderWidth = 2
        newUserPicture.layer.masksToBounds = false
        newUserPicture.layer.borderColor = UIColor.grayColor().CGColor
        newUserPicture.layer.cornerRadius = newUserPicture.frame.height/2
        newUserPicture.clipsToBounds = true
        
        

        
        addFriendButton.layer.borderWidth = 2
        addFriendButton.backgroundColor = UIColor.clearColor()
        addFriendButton.layer.cornerRadius = 4
        addFriendButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 149.0/255.0, alpha: 1.0).CGColor
        
        allowOnceButton.layer.borderWidth = 2
        allowOnceButton.backgroundColor = UIColor.clearColor()
        allowOnceButton.layer.cornerRadius = 4
        allowOnceButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
        
        blockUserButton.layer.borderWidth = 2
        blockUserButton.backgroundColor = UIColor.clearColor()
        blockUserButton.layer.cornerRadius = 4
        blockUserButton.layer.borderColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0).CGColor
        

        
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)

        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    @IBAction func blockUser(sender: AnyObject) {
        self.delegate?.updateUserStatus("blocked")
        self.performSegueWithIdentifier("unwindToMessages", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func allowOnce(sender: AnyObject) {
        self.delegate?.updateUserStatus("once")
        self.delegate?.updateAllowOnce()
        self.delegate?.photoAppear()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func addFriend(sender: AnyObject) {
        self.delegate?.updateUserStatus("friend")
        self.delegate?.photoAppear()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
