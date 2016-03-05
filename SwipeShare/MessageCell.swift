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
    
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet var messageImageView: UIImageView!
    @IBOutlet var sentDate: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageImageView.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageImageView.layer.cornerRadius = messageImageView.bounds.width / 8.0
        

    }

    

    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    

    
}
