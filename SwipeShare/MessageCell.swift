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

    @IBOutlet var sentDate: UILabel!

    @IBOutlet weak var sentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

    }

    

    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    

    
}
