//
//  MessageDetailVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/6/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

import UIKit

class MessageDetailVC: UIViewController{


    var message: Message!
    
    
    
    @IBOutlet weak var messageSenderLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        messageSenderLabel.text = String(message.sender["username"])
        messageImageView?.image = message.image
    }
    
}
