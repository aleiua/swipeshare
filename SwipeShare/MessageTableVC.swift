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
//    var blockedUsers = [BlockedUser]()
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    // ** CREATE MESSAGE MANAGER **
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch list of friends by username from CoreData
        let friendFetchRequest = NSFetchRequest(entityName: "Friend")

        do {
            fetchedFriends = try managedContext.executeFetchRequest(friendFetchRequest) as! [Friend]
            print("going to print friend count")
            print(fetchedFriends.count)
        } catch {
            print("error fetching friend list from CoreData")
        }
        
        // Fetch list of blocked users by username from CoreData (unneeded at present)
//        let blockedFetchRequest = NSFetchRequest(entityName: "BlockedUser")
//        
//        do {
//            blockedUsers = try managedContext.executeFetchRequest(blockedFetchRequest) as! [BlockedUser]
//            print(blockedUsers.count)
//        } catch {
//            print("error fetching list of blocked users")
//        }
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
    
    // Swipe left on a message to delete (will only remove from temporary store)
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.Delete {
//            
//            print("COMMIT EDITING")
////            messageManager.messages.removeAtIndex(indexPath.row)
////            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            
//            // send to parse that message has been removed!!
//        }
//    }

    /*********/
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: " Delete ", handler:{action, indexpath in
            self.messageManager.messages.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        });
        deleteAction.backgroundColor = UIColor.redColor()
        
        
        let blockAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "  Block  \n  User", handler:{action, indexpath in
            print("MORE•ACTION");
        });
        blockAction.backgroundColor = UIColor.lightGrayColor();
        
        
        
        
        
        return [deleteAction, blockAction]
    }
    
    //empty implementation
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//    }

    /*************/
    
    
    
    func messageCellAtIndexPath(indexPath: NSIndexPath) -> MessageCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellIdentifier) as! MessageCell
        
        
        let msg = messageManager.messages[indexPath.row] as Message
        cell.senderLabel.text = String(msg.sender["name"])
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
//        cell.senderLabel?.text = String(message.sender["name"])
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
            
            // Prompt user for action if message is from a non-friend user
            if !isFriend(message.sender.username!) {
                
                print("received message from non-friend")
                saveFriend(message.sender.username!)
                destinationViewController.message = message
                

//                // If user decides to "add friend," add them and continue to the message
//                if (addFriend) {
//                    saveFriend(message.sender.username!)
//                    destinationViewController.message = message
//                }
                
//                // If user decides to "add friend later" simply continue to view the message
//                if (addFriendLater) {
//                    destinationViewController.message = message
//                }
                
                
//                //If user decides to "block," block the user and hide the message
//                if(block) {
//                  blockUser(message.sender.username)
//                  //hide message
//                  self.tableView.deleteRowsAtIndexPaths([self.tableView.indexPathForSelectedRow!], withRowAnimation: UITableViewRowAnimation.Automatic)
//                  messageManager.messages.removeAtIndex(self.tableView.indexPathForSelectedRow!.row)
//                }
                
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
    
    // Called when user decides to block another user
    // Saves a corresponding BlockedUser entity to CoreData
    func blockUser(username: String) {
        
        // Save to CoreData
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("BlockedUser", inManagedObjectContext: managedObjectContext)
        let blockedUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:  managedObjectContext)
        blockedUser.setValue(username, forKey: "username")
        
        do {
            try managedObjectContext.save()
            print("successfully blocked user")
        } catch let error {
            print("error blocking user in managedObjectContext: \(error)")
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

    
    



