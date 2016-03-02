//
//  MessageCell.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit



class MessageCell: UITableViewCell {
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var receiverLable: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!

    
    

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

    
}
