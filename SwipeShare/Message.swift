//
//  Message.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import Parse

class Message {
    
    var sender: PFObject
    var image: UIImage?
    
    
    // Set text and image to default "nil" if they are not part of the message
    // Could be problematic with unwrapping that comes later ***
    init(sender: PFObject, image: UIImage? = nil) {
        self.sender = sender
        self.image = image
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let sender = dictionary["sender"]
        
        // Purposeful application crash/error - only used in debugging
        assert(sender != nil, "the message must have a sender and receiver")
        
        
        let imageData = dictionary["image-data"] as? NSData
        var image: UIImage?
        if imageData != nil {
            image = UIImage(data: imageData!)
        }
        
        self.init(sender: sender! as! PFObject, image: image)
    }
    
    
    
    func toPropertyListObject() -> NSDictionary {
        
        let dictionary: NSMutableDictionary = ["sender" : sender]
        
        if image != nil {
            dictionary["image-data"] = UIImageJPEGRepresentation(image!, 0.7)
            
        }
        return dictionary
        
    }
}
