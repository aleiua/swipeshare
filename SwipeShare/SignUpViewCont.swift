//
//  SignupViewCont.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class SignUpViewCont: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func submit(sender: AnyObject) {
        usernameField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        if (username == "" || password == "")
        {
            print("NOTHING ENTERED")
            return
        }
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signUpInBackgroundWithBlock( {  (newUser, error) -> Void in
            
            spinner.stopAnimating()
            
       

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LocationViewController")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
            print("logged in as:")
            print(PFUser.currentUser()!.username)
               


        })
        
        // For RSSI:
        // Find the highest preexisting userID and assign a new one with the previous value incremented
        var currentIdentifier = 0
        var query = PFQuery(className:"_User")
        query.orderByDescending("identifier")
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            // Failure
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            }
            
            // If successful, increment the identifier and reassign with a subsequent query
            else {
                print("Successfully retrieved the object.")
                let maxIdentifier = object!["identifier"] as! Int
                currentIdentifier = maxIdentifier + 1
                
                query = PFQuery(className: "_User")
                query.whereKey("username", equalTo: PFUser.currentUser()!)
                query.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!) {
                    (user: PFObject?, error: NSError?) -> Void in
                    
                    // Failure
                    if error != nil {
                        print("failed to get current user object for setting unique identifier")
                    }
                    
                    // Save the new user identifier to parse
                    else if let user = user {
                        user["identifier"] = currentIdentifier
                        user.saveInBackground()
                        print("successfully saved new user identifier of value: \(currentIdentifier)")
                    }
                }
            }
        }
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
