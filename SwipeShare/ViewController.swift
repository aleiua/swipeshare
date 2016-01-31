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

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let alert = UIAlertController()
    
    
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
                self.alert.title = error.userInfo.debugDescription
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                self.alert.addAction(defaultAction)
                
                
                self.presentViewController(self.alert, animated: true, completion: nil)
                
                // Bring the keyboard back up, because they probably need to change something.
                self.username.becomeFirstResponder()
                self.username.text = "";
                self.password.text = "";
                return;

            } else {
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

