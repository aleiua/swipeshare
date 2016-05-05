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
    
    @NSManaged var user: User
    
    
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
}
