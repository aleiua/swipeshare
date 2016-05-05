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
    let sender: User? = nil
    
    @IBOutlet weak var blurredBackgroundView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEditing(true, animated: true)
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
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func addFriend(sender: AnyObject) {
        self.delegate?.updateUserStatus("friend")
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
