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


class ViewController: UIViewController, UITableViewDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var delegate: LocationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("What up, in view controller")
        if (PFUser.currentUser() == nil) {
            
            
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton, .Facebook]
            
            loginViewController.facebookPermissions = ["email", "public_profile", "user_friends"]

            loginViewController.emailAsUsername = false
            loginViewController.signUpController?.emailAsUsername = false
            loginViewController.signUpController?.delegate = self

            

                        
            self.presentViewController(loginViewController, animated: false, completion: nil)
        }
            
        else {
            let locationViewController = UIStoryboard.locationViewController()

            self.presentViewController(locationViewController!, animated: true, completion: nil)
        }
    }
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)

        if (PFUser.currentUser() != nil && FBSDKAccessToken.currentAccessToken() != nil && PFUser.currentUser()!.isNew) {
            print("First time Facebook User")
            self.storeFacebookData()
            self.storeBluetoothID(user)
        }
        else if (FBSDKAccessToken.currentAccessToken() != nil) {
            
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        if (PFUser.currentUser() != nil) {
            let user = PFUser.currentUser()
            user!["name"] = user!["username"]
            user?.saveInBackground()
        }
        self.storeBluetoothID(user)
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
    
    /*************************** Bluetooth Data ******************************/
     
    func storeBluetoothID(user : PFUser) {
        var currentIdentifier = 0
        var query = PFQuery(className:"_User")
        
        // Determine the highest current identifier in Parse
        query.orderByDescending("btIdentifier")
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            // Failure
            if (error != nil || object == nil) {
                print("Failed to retrieve btIdentifier.")
            }
                
                // If successful, increment the identifier and reassign with a subsequent query
            else {
                let maxIdentifier = object!["btIdentifier"] as! Int
                currentIdentifier = maxIdentifier + 1
                
                query = PFQuery(className: "_User")
                query.whereKey("objectId", equalTo: user.objectId!)
                do {
                    let userArray = try query.findObjects()
                    print(userArray)
                    userArray[0]["btIdentifier"] = currentIdentifier
                    userArray[0].saveInBackground()
                    print("successfully saved \(user.username!) with identifier of value: \(currentIdentifier)")
                    
                } catch {
                    print("Failed to get matching user")
                }
            }
        }
    }
    
    
    /*************************** Facebook Data ******************************/
    
    func storeFacebookData() {
        print("Storing FB Data")
        
        let user = PFUser.currentUser()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        
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
                    let jpgImage = UIImageJPEGRepresentation(image!, 1.0)
                    let imageFile = PFFile(name: "image.jpg", data: jpgImage!)
                    
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
    
    func storeProfilePicture() {
        let user = PFUser.currentUser()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil)
            {
                
                // Get Profile Picture
                let userID: NSString = (result.valueForKey("id") as? NSString)!
                let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                
                if let data = NSData(contentsOfURL: facebookProfileUrl!) {
                    let image = UIImage(data: data)
                    
                    // Convert to Parse Format
                    let jpgImage = UIImageJPEGRepresentation(image!, 1.0)
                    let imageFile = PFFile(name: "image.jpg", data: jpgImage!)
                    
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


private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    
    
    class func locationViewController() -> LocationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController
        
    }

    
}



