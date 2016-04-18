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
    override func viewDidLoad() {
        print("loaded settings view controller")
        super.viewDidLoad()
        
        userIcon.layer.borderWidth = 5
        userIcon.layer.masksToBounds = false
        userIcon.layer.borderColor = UIColor.grayColor().CGColor
        userIcon.layer.cornerRadius = userIcon.frame.height/2
        userIcon.clipsToBounds = true
        
    }
    
    @IBAction func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            self.presentViewController(viewController, animated: true, completion: nil)
            
        })    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}