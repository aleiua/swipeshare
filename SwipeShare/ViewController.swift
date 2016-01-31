//
//  ViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 1/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

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
                // Show the errorString somewhere and let the user try again.
                print(error.userInfo.description)

            } else {
                // Hooray! Let them use the app now.
            }
        }
        print("User submitted password")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

