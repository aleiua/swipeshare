//
//  SignupViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func submit(sender: AnyObject) {
        if (username.text == "" || password.text == "")
        {
            print("NOTHING ENTERED")
            return
        }
        
        let user = PFUser()
        user.username = username.text
        user.password = password.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            
            if let error = error {
                
                // Display an alert view to show the error message
                if (error.code == 202) {
//                    self.alert.title = "Username alredy in use"
//                    self.alert.message = "Please choose a new username"
                }
                
                // Incase we simply want to pipe the exact error message to the title, use the following line
                //self.alert.title = error.userInfo.debugDescription
                
                
//                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//                self.alert.addAction(defaultAction)
                
                
//                self.presentViewController(self.alert, animated: true, completion: nil)
                
                
                
                //                // Bring the keyboard back up, because they probably need to change something.
                //                self.username.becomeFirstResponder()
                //                self.username.text = "";
                //                self.password.text = "";
                
            } else {
                // Move on to next interface
                self.performSegueWithIdentifier("infoSubmitted", sender: nil)
            }
        }
        print("User submitted password")
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
