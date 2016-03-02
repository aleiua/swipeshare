//
//  LoginViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var username = ""
    var password = ""
    

    
    
    @IBAction func loginAction(sender: AnyObject) {
        usernameField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
        
        // ---- No username or password entered -----
        if (self.usernameField.text == "" || self.passwordField.text == "")
        {
            let usernameAlertController = UIAlertController(title: "Login Error", message: "Enter your username and password", preferredStyle: .Alert)
            
            let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in }

            usernameAlertController.addAction(OkAction)
            
            self.presentViewController(usernameAlertController, animated: true, completion: nil)
        
            return
        }

        username = self.usernameField.text!
        password = self.passwordField.text!

        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        
        
        // ---- Logging In -----
        
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
            
            spinner.stopAnimating()
            
            
            // ---- If login was successful -----
            if (user != nil) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LocationViewController")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
                
                print(self.username)
                
                
            // ---- Unsuccessful login -----
            } else {
                let loginAlertController = UIAlertController(title: "Login Error", message: "Failed Login. Try again.", preferredStyle: .Alert)
                
                let OkAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                loginAlertController.addAction(OkAction)
                
                self.presentViewController(loginAlertController, animated: true, completion: nil)
                
            }
            
        })
        
    }
    
    // Integrating Facebook Login

    //func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    //{
    //    if(error != nil)
    //    {
    //        print(error.localizedDescription)
    //        return
    //    }
    //    
    //    //if let userToken = result.token
    //    if result.token != nil
    //    {
    //        //Get user access token
    //        //let token:FBSDKAccessToken = result.token
    //        print("Token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
    //        
    //        print("User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
    //        
    //        let mainPage = self.storyboard?.instantiateViewControllerWithIdentifier("LocationViewController")
    //        let mainPageNav = UINavigationController(rootViewController: mainPage!)
    //        
    //        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //        
    //        appDelegate.window?.rootViewController = mainPageNav
    //        
    //    }
    //}



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
