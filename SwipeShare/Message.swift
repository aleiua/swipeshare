//
//  Message.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Parse

@objc(Message)

class Message: NSManagedObject  {
    
    var sender: PFUser
    var image: UIImage?
    var date: NSDate
    var id: String
    
    // Set text and image to default "nil" if they are not part of the message
    // Could be problematic with unwrapping that comes later ***
    init(sender: PFUser, image: UIImage? = nil, date: NSDate, id: String) {
        self.sender = sender
        self.image = image
        self.date = date
        self.id = id
    }
    
    // ID is an entirely optional parameter
    init(sender: PFUser, image: UIImage? = nil, date: NSDate) {
        self.sender = sender
        self.image = image
        self.date = date
        self.id = ""
    }
    
//    init(sender: String, date: NSDate, imageData: NSData, objectId: String) {
//        super.init()
//        self.sender = sender
//        self.imageData = imageData
//        self.date = date
//        self.objectId = objectId
//    }
//    
//    init(sender: PFUser, image: UIImage? = nil, date: NSDate) {
//        self.sender = sender
//        self.image = image
//        self.date = date
//    }
//    
//    convenience init(dictionary: NSDictionary) {
//        
//        let sender = dictionary["sender"]
//        let date = dictionary["date"]
//        
//        
//        let imageData = dictionary["image-data"] as? NSData
//        var image: UIImage?
//        if imageData != nil {
//            image = UIImage(data: imageData!)
//        }
//        
//        
//        self.init(sender: sender! as! PFUser, image: image, date: date! as! NSDate)
//    }
//    
//    
//    
//    func toPropertyListObject() -> NSDictionary {
//        
//        let dictionary: NSMutableDictionary = ["sender" : sender]
//        dictionary["date"] = date
//
//        
//        if image != nil {
//            dictionary["image-data"] = UIImageJPEGRepresentation(image!, 0.7)
//            
//        }
//        
//        
//        return dictionary
//        
//    }
}
