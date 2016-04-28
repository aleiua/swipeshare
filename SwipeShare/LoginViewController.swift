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


class LoginViewController: PFLogInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpController = SignUpViewCont()
        self.signUpController!.fields = [.UsernameAndPassword, .SignUpButton, .DismissButton]

        // Remove the parse Logo
        let logo = UILabel()
        logo.text = "Yaw"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80)
//        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        
        self.view.backgroundColor = UIColor(red: 0.21, green: 0.27, blue: 0.31, alpha: 1.0)
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        // position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)
    }
}
