//
//  MessageTableVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Parse

class MessageTableVC: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    let messageCellIdentifier = "MessageCell"
    let messageManager = MessageManager.sharedMessageManager
    
    
    // ** CREATE MESSAGE MANAGAER **
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedMessages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Message")
        print("setting up fetch request")
        
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            fetchedMessages = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Message]
            
        } catch {
            fatalError("Failed to fetch messages: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedMessages.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return messageCellAtIndexPath(indexPath)
        
        
        
    }
    
    func messageCellAtIndexPath(indexPath: NSIndexPath) -> MessageCell {
        
        
        print("fetching messages: ")
        print(fetchedMessages.count)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellIdentifier) as! MessageCell
        let msg = fetchedMessages[indexPath.row] as Message
        cell.senderLabel.text = String(msg.sender)
//        if msg.imageData != nil {
//            cell.messageImageView.image = UIImage(data: msg.imageData!)
//        }
        
        //let msg = messageManager.messages[indexPath.row] as Message
        cell.senderLabel.text = String(msg.sender)
//        cell.messageImageView?.image = msg.image
        
        //DATE FORMATING NEEDS TO BE REWORKED FOR COREDATA
        //            let date = NSDateFormatter.localizedStringFromDate(NSDate(msg.date), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        cell.sentDate.text = String(msg.date)
        return cell

 
        }

        
        
        // OLD
        
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellIdentifier) as! MessageCell
//        
//        let msg = messageManager.messages[indexPath.row] as Message
//        cell.senderLabel.text = msg.sender["username"]
//        cell.messageImageView?.image = msg.image
//        
//
//        let date = NSDateFormatter.localizedStringFromDate(msg.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
//        cell.sentDate.text = date
//        
        
//        return cell
        

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
        
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "messageDetailSegue" {
            
            let destinationViewController = segue.destinationViewController as! MessageDetailVC
            
        
                
            let message = fetchedMessages[tableView.indexPathForSelectedRow!.row]
            destinationViewController.message = message
            
        }
    }
}

    
    



