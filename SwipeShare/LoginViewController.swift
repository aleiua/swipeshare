//
//  LoginViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func loginAction(sender: AnyObject) {
        usernameField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // ---- No username entered -----
        if (username == "" )
        {
            let alertController = UIAlertController(title: "Login Error", message: "Enter your username", preferredStyle: .Alert)
            
            let OkAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OkAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
            
        // ---- No password entered -----
        else if (password == "") {
            let alertController = UIAlertController(title: "Login Error", message: "Enter your password", preferredStyle: .Alert)
            
            let OkAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OkAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        
        
        // ---- Logging In -----
        
        PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
            
            spinner.stopAnimating()
            
            
            // ---- If login was successful -----
            if (user != nil) {

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LocationViewController")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
                
                print(username)
                
                
            // ---- Unsuccessful login -----
            } else {
                let alertController = UIAlertController(title: "Login Error", message: "Failed Login. Try again.", preferredStyle: .Alert)
                
                let OkAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(OkAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)

            }
            
        })
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if(error != nil)
        {
            print(error.localizedDescription)
            return
        }
        
        //if let userToken = result.token
        if result.token != nil
        {
            //Get user access token
            //let token:FBSDKAccessToken = result.token
            print("Token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            
            print("User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            let mainPage = self.storyboard?.instantiateViewControllerWithIdentifier("LocationViewController")
            let mainPageNav = UINavigationController(rootViewController: mainPage!)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = mainPageNav
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let fbLoginButton = FBSDKLoginButton
//        
//        fbLoginButton.center = self.view.center
        
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
