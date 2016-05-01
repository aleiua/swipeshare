//
//  Message.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData


class Message: NSManagedObject  {
    
    typealias ObjectId = String
    typealias SenderId = String
    
    
    @NSManaged var sender: SenderId
    @NSManaged var date: NSDate
    @NSManaged var imageData: NSData?
    @NSManaged var objectId: ObjectId
    @NSManaged var hasBeenOpened: Bool
    
    
    convenience init(sender: String, date: NSDate, imageData: NSData? = nil, objectId: String, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.sender = sender
        self.date = date
        self.objectId = objectId
        self.hasBeenOpened = false
        
        if imageData != nil {
            self.imageData = imageData
        }
    }
    
//   convenience init(dictionary: NSDictionary) {
//
//        let sender = dictionary["sender"]
//        let date = dictionary["date"]
//        
//        // Purposeful application crash/error - only used in debugging
//        assert(sender != nil, "the message must have a sender and receiver")
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
    
    
    }
