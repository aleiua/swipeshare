//
//  User.Swift
//  SwipeShare
//
//  Created by A. Lynn on 3/4/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData


class User: NSManagedObject  {
    
    
    @NSManaged var username: String
    @NSManaged var displayName: String
    @NSManaged var status: String?
    @NSManaged var profImageData: NSData?
    @NSManaged var mostRecentCommunication: NSDate
    
    
    convenience init(username: String, displayName: String, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.username = username
        self.displayName = displayName
        self.status = nil
        self.profImageData = nil
        self.mostRecentCommunication = NSDate()
    }
}
