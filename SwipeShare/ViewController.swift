//
//  ViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 1/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBAction func MapButton(sender: AnyObject) {
    }
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let alert = UIAlertController(title: "Error", message: "Message", preferredStyle: .Alert)
    
    
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
                    self.alert.title = "Username alredy in use"
                    self.alert.message = "Please choose a new username"
                }
                
                // Incase we simply want to pipe the exact error message to the title, use the following line
                //self.alert.title = error.userInfo.debugDescription
                
                
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                self.alert.addAction(defaultAction)
                
                
                self.presentViewController(self.alert, animated: true, completion: nil)
                
                
                
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
        // Do any additional setup after loading the view, typically from a nib.
        
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

}

