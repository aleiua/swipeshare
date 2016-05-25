//
//  CurrentUserProfile.swift
//  SwipeShare
//
//  Created by Troy Palmer on 5/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData


class CurrentUserProfile: NSManagedObject  {
    
    
    @NSManaged var username: String
    @NSManaged var displayName: String
    @NSManaged var profImageData: NSData?
    @NSManaged var maxDistanceSetting: NSNumber
    @NSManaged var shareWithFriendsSetting: Bool
    
    convenience init(username: String, displayName: String, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.username = username
        self.displayName = displayName
        self.profImageData = nil
        self.shareWithFriendsSetting = false
        self.maxDistanceSetting = 100.0
        
    }
}
