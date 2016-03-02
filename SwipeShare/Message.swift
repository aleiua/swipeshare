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

class Message {
    
    var sender: String
    var receiver: String
    var text: String?
    var image: UIImage?
    
    
    // Set text and image to default "nil" if they are not part of the message
    // Could be problematic with unwrapping that comes later ***
    init(sender: String, receiver: String, text: String? = nil, image: UIImage? = nil) {
        self.sender = sender
        self.receiver = receiver
        self.text = text
        self.image = image
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let sender = dictionary["sender"] as? String
        let receiver = dictionary["receiver"] as? String
        
        
        // Purposeful application crash/error - only used in debugging
        assert(sender != nil && receiver != nil, "the message must have a sender and receiver")
        
        let text = dictionary["text"] as? String
        
        
        let imageData = dictionary["image-data"] as? NSData
        var image: UIImage?
        if imageData != nil {
            image = UIImage(data: imageData!)
        }
        
        self.init(sender: sender!, receiver: receiver!, text: text!, image: image)
    }
    
    
    
    func toPropertyListObject() -> NSDictionary {
        
        let dictionary: NSMutableDictionary = ["sender" : sender, "receiver" : receiver]
        
        if text != nil {
            dictionary["text"] = text!
        }
        
        if image != nil {
            dictionary["image-data"] = UIImageJPEGRepresentation(image!, 0.7)
            
        }
        return dictionary
        
    }
}
