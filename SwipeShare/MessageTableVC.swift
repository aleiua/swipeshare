//
//  MessageTableVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/2/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation


import UIKit
import Parse
import CoreData

class MessageTableVC: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    let messageCellIdentifier = "MessageCell"
    let messageManager = MessageManager.sharedMessageManager
    
    var fetchedFriends = [Friend]()
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // ** CREATE MESSAGE MANAGER **
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch list of friends by username from CoreData
        let fetchRequest = NSFetchRequest(entityName: "Friend")

        do {
            fetchedFriends = try managedContext.executeFetchRequest(fetchRequest) as! [Friend]
            print("going to print friend count")
            print(fetchedFriends.count)
        } catch {
            print("error")
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
        return messageManager.messages.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return messageCellAtIndexPath(indexPath)
        
    }
    
    func messageCellAtIndexPath(indexPath: NSIndexPath) -> MessageCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellIdentifier) as! MessageCell
        
        let msg = messageManager.messages[indexPath.row] as Message
        cell.senderLabel.text = String(msg.sender["username"])
//        cell.messageImageView?.image = msg.image
        

        let date = NSDateFormatter.localizedStringFromDate(msg.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        cell.sentDate.text = date
        
        return cell
        
    }
    

        
//        let cell = self.tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
//        
//        
//        var message: Message
//        
//        let messageManager = MessageManager.sharedMessageManager
//        print("MessageManager Count:")
//        print(messageManager.messages.count)
//        
//        message = messageManager.messages[indexPath.row]
//        
//        cell.senderLabel?.text = String(message.sender["username"])
//        cell.messageImageView?.image = message.image
//        
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
            
        
                
            let message = messageManager.messages[tableView.indexPathForSelectedRow!.row]
            
            if !isFriend(message.sender.username!) {
                
                //Prompt the user for action
                print("received message from non-friend")
                saveFriend(message.sender.username!)
                destinationViewController.message = message
            }
            else {
                print("message was sent from friend")
                destinationViewController.message = message
            }
            
        }
    }
    
    
    // Called when a message is received from a new user to save friend to CoreData
    func saveFriend(username: String) {
        
        // Save to CoreData
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: managedObjectContext)
        let friend = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
        friend.setValue(username, forKey: "username")
        
        do {
            try managedObjectContext.save()
            print("successfully saved friend")
        } catch let error {
            print("error saving new friend in managedObjectContext: \(error)")
        }
    }
    
    // Check to see if the user is a friend
    func isFriend(username: String) -> Bool {
        
        for friend in fetchedFriends {
            print(friend.username)
            if friend.username == username {
                return true
            }
        }
        return false
    }
}

    
    



