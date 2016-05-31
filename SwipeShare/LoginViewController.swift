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
        logo.textColor = UIColor.orangeColor()
        logo.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80)
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        customizeButton(logInView?.logInButton!)
        
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.orangeColor(), forState: .Normal)

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
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)
    }
}
