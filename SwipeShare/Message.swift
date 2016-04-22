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
    
    typealias ObjectId = String
    typealias SenderId = String

    
    @NSManaged var sender: SenderId
    @NSManaged var date: NSDate
    @NSManaged var imageData: NSData?
    @NSManaged var objectId: ObjectId
    
    
    // Set text and image to default "nil" if they are not part of the message
    // Could be problematic with unwrapping that comes later ***
//    
//    init(entity: NSEntityDescription, insertIntoManagedObjectContext
//        context: NSManagedObjectContext?,
//        sender: String,
//        date: NSDate,
//        imageData: NSData? = nil,
//        objectId: String) {
//        //init
//    }

    convenience init(sender: String, date: NSDate, imageData: NSData? = nil, objectId: String, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.sender = sender
        self.date = date
        self.objectId = objectId
        
        if imageData != nil {
            self.imageData = imageData
        }
    }
    

}
