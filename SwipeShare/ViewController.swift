//
//  LoginViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/3/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import LocationKit

import FBSDKCoreKit
import ParseFacebookUtilsV4


class ViewController: UIViewController, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            
            
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton, .Facebook]

            loginViewController.emailAsUsername = false
            loginViewController.signUpController?.emailAsUsername = false
            loginViewController.signUpController?.delegate = self

            

                        
            self.presentViewController(loginViewController, animated: false, completion: nil)
        }
            
        else {
//            presentLoggedInAlert()
        }
    }
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)

        if (PFUser.currentUser() != nil && FBSDKAccessToken.currentAccessToken() != nil) {
            self.storeFacebookData()
        }
        
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        if (PFUser.currentUser() != nil) {
            let user = PFUser.currentUser()
            user!["name"] = user!["username"]
            user?.saveInBackground()
        }
    }
    

    func presentLoggedInAlert() {
        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Yaw", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    /*************************** Facebook Data ******************************/
    
    func storeFacebookData() {
        
        print("GRABBING FB DATA FOR NON FACEBOOK USER")

        let user = PFUser.currentUser()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name, picture"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil)
            {
                print("result \(result)")
                // Store new FB Name
                let name = result.valueForKey("name") as! String
                user!["name"] = name

                // Get Profile Picture
                let userID: NSString = (result.valueForKey("id") as? NSString)!
                let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")

                if let data = NSData(contentsOfURL: facebookProfileUrl!) {
                    let image = UIImage(data: data)
                    
                    // Convert to Parse Format
                    let imageData = UIImagePNGRepresentation(image!)
                    let imageFile = PFFile(name: "image.png", data:imageData!)
                    
                    user!["profilePicture"] = imageFile
                    
                }
                
                user?.saveInBackground()
            }
            else
            {
                print("error \(error)")
            }
        })
        return
    }
    

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
