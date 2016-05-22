//
//  UserCell.swift
//  SwipeShare
//
//  Created by A. Lynn on 5/22/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

import Foundation
import UIKit



class UserCell: UITableViewCell {
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var sentDate: UILabel!
    
    @IBOutlet weak var profilePictureThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureThumbnail.layer.borderWidth = 1
        profilePictureThumbnail.layer.masksToBounds = false
        profilePictureThumbnail.layer.borderColor = UIColor.grayColor().CGColor
        profilePictureThumbnail.layer.cornerRadius = profilePictureThumbnail.frame.height/2
        profilePictureThumbnail.clipsToBounds = true

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
