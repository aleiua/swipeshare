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


class SignUpViewCont: PFSignUpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Remove the parse Logo
        let logo = UILabel()
        logo.text = "Yaw"
        logo.textColor = UIColor.orangeColor()
        logo.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80)
        logo.shadowOffset = CGSizeMake(2, 2)
        signUpView?.logo = logo
        customizeButton(signUpView?.signUpButton!)

    }
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.orangeColor().CGColor
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
    }

    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        // position logo at top with larger frame
        signUpView!.logo!.sizeToFit()
        let logoFrame = signUpView!.logo!.frame
        signUpView!.logo!.frame = CGRectMake(logoFrame.origin.x, signUpView!.usernameField!.frame.origin.y - logoFrame.height - 16, signUpView!.frame.width,  logoFrame.height)
    }
    
}
