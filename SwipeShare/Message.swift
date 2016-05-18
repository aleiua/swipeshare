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
    
    
    @NSManaged var date: NSDate
    @NSManaged var imageData: NSData?
    @NSManaged var objectId: ObjectId
    @NSManaged var hasBeenOpened: Bool
    @NSManaged var allowedOnce: Bool
    
    @NSManaged var user: User
    
    
    convenience init(date: NSDate, imageData: NSData? = nil, objectId: String, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.date = date
        self.objectId = objectId
        self.hasBeenOpened = false
        self.allowedOnce = false
        
        if imageData != nil {
            self.imageData = imageData
        }
    }
}
