//
//  FriendDetailView.swift
//  SwipeShare
//
//  Created by A. Lynn on 5/9/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation




import UIKit
import Parse
import CoreData

class FriendDetailView: UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var userProfPic: UIImageView!

    var user: User!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController!.toolbarHidden = false
//        self.navigationController!.hidesBarsOnTap = true
            print("we are here in friend detail veiw")
        
        
//        messageNavBar.title = String(message.user.displayName)
//        let date = NSDateFormatter.localizedStringFromDate(message.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
//        messageNavBar.rightBarButtonItem?.title = date
        if user.profImageData != nil{
            print("we have prof image data2")
            userProfPic.image = UIImage(data: user.profImageData!)
        } else {
            userProfPic.image = UIImage(named: "userIcon")
            
        }
        
        
        
    
    
    }

}