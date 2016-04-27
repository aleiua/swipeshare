//
//  CheckListViewController.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 4/7/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class BumpValidationViewController: UIViewController {
    var recipient = [PFObject]()
    var delegate: LocationViewController? = nil
    
    @IBOutlet weak var blurredBackgroundView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    

    
    @IBAction func sendMessage(sender: AnyObject) {
        delegate?.sendToUsers(recipient, bluetooth: true)
        delegate?.refreshSymbol()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEditing(true, animated: true)
        navBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        let name = recipient[0]["name"]
        navBar.topItem!.title = "Send photo to \(name)?"
        
        //        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.effect as! UIBlurEffect)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
