//
//  SignUpVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 2/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse


class SignUpVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
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
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            
            spinner.stopAnimating()
            
            if ((error) != nil) {
                print("signup error:")
                print(error)
                
            } else {
                print("signup succes!")
                
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LocationViewController")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
            }
        }
        
    }
    
    @IBAction func cancelToPlayersViewController(segue:UIStoryboardSegue) {
        
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
