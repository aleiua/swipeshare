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
    
    @NSManaged var sender: String?
    @NSManaged var date: NSDate?
    @NSManaged var imageData: NSData?
    @NSManaged var objectId: String?
    
    
    override init(entity: NSEntityDescription,
        insertIntoManagedObjectContext context: NSManagedObjectContext!) {
            super.init(entity: entity, insertIntoManagedObjectContext: context)
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
