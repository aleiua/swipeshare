//
//  MessageManager.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

import UIKit

private let messageManagerInstance = MessageManager()

class MessageManager {
    
    var messages = [Message]()
    
    class var sharedMessageManager: MessageManager {
        return messageManagerInstance
    }
    
    func documentsDirectoryPaths() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        
        return paths.first!
    }
    
    func addMessage(msg : Message) {
        messages.append(msg)
    }
    
    
    func saveMessages() {
        let docPath = documentsDirectoryPaths()
        let messagesFilePath = (docPath as NSString).stringByAppendingPathComponent("messages.plist")
        
        let messagePropertyListObjects = NSMutableArray()
        for msg in messages {
            messagePropertyListObjects.addObject(msg.toPropertyListObject())
        }
        
        let data = try? NSPropertyListSerialization.dataWithPropertyList(messagePropertyListObjects, format: .XMLFormat_v1_0, options: 0)
        data?.writeToFile(messagesFilePath, atomically: true)
    }
    
    func loadMessages() {
        let messagesFilePath = (documentsDirectoryPaths() as NSString).stringByAppendingPathComponent("messages.plist")
        
        let plistData: NSData? = NSData(contentsOfFile: messagesFilePath)
        if plistData != nil {
            let messagePropertyListObjects =  try? NSPropertyListSerialization.propertyListWithData(plistData!, options: NSPropertyListMutabilityOptions.MutableContainers, format: nil)
            
            for messageDictionary in messagePropertyListObjects as! NSArray {
                let message = Message(dictionary: messageDictionary as! NSDictionary)
                messages.append(message)
                
            }
        }
    }
}