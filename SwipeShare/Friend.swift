//
//  Friend.swift
//  SwipeShare
//
//  Created by Troy Palmer on 4/18/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Parse

//@objc(Friend)

class Friend: NSManagedObject {
    
    @NSManaged var username: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}