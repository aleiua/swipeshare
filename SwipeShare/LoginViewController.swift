//
//  LoginViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse
import LocationKit

import FBSDKCoreKit
import ParseFacebookUtilsV4



class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func loginAction(sender: AnyObject) {
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
        
        
        PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
            
            spinner.stopAnimating()
            
            if (user != nil) {

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContainerViewController")
                    self.showViewController(viewController, sender: self)
                })
                
                print(username)
                
            } else {
                print("login error")
            }
            
        })
        
    }
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    
    @IBAction func loginToFacebook(sender: AnyObject) {
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(facebookReadPermissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
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
