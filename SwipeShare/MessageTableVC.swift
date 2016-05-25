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
    //let messageManager = MessageManager.sharedMessageManager
    
    let photoUtils = Utilities()
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    // var users: [User] = [User]()
    var fetchedMessages: [Message] = [Message]()
    var users: [User] = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMessagesFromCore()
        
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(MessageTableVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // just counting the users
        
        let fetchUsers = NSFetchRequest(entityName: "User")
        do {
            users = try managedContext.executeFetchRequest(fetchUsers) as! [User]
        } catch {
            fatalError("Failed to fetch messages: \(error)")
        }
        print("users stored: ")
        print(users.count)
    }
    
    
    func getMessagesFromCore() {
        
        
        // Fetch messages from core Data, sorted by date
        let messageFetchRequest = NSFetchRequest(entityName: "Message")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) // Puts newest messages on top
        messageFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            fetchedMessages = try managedContext.executeFetchRequest(messageFetchRequest) as! [Message]
        } catch {
            fatalError("Failed to fetch messages: \(error)")
        }
        

        
    }
    
    
    @IBAction func refresh(sender: AnyObject) {
        print("trying to refresh")
        
        self.getDataFromParse()
        
        self.getMessagesFromCore()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
    }
    
    func getDataFromParse() {
        let locationViewCont = LocationViewController()
        
        locationViewCont.getPictureObjectsFromParse()
        print("trying to get data from Parse")
        
        
    }
    
    
    
    // Makes sure tab bar navbar doesn't overlap.
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            self.tableView.contentInset = UIEdgeInsetsMake( 0, 0, self.bottomLayoutGuide.length, 0)
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
    
    func deleteMessage() {
        self.tableView.deleteRowsAtIndexPaths([self.tableView.indexPathForSelectedRow!], withRowAnimation: UITableViewRowAnimation.Automatic)
        //messageManager.messages.removeAtIndex(self.tableView.indexPathForSelectedRow!.row)
    }
    
    
    // Simple delete functionality for rows
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let itemToDelete = fetchedMessages[indexPath.row]
            managedContext.deleteObject(itemToDelete)
            fetchedMessages.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

//    // Enables more functionality.
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//
//        
//        // FIGURE OUT DELETING FROM CORE DATAAAA
//        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: " Delete ", handler:{action, indexpath in
//            //self.messageManager.messages.removeAtIndex(indexPath.row)
//            self.fetchedMessages.removeAtIndex(indexPath.row)
//
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//        });
//        deleteAction.backgroundColor = UIColor.redColor()
//        
//        
//        let blockAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "  Block  \n  User", handler:{action, indexpath in
//        });
//        blockAction.backgroundColor = UIColor.lightGrayColor();
//        
//        
//        return [deleteAction, blockAction]
//    }
    

    
    
    
    func messageCellAtIndexPath(indexPath: NSIndexPath) -> MessageCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellIdentifier) as! MessageCell
        let msg = fetchedMessages[indexPath.row] as Message
        
        if msg.hasBeenOpened == false {
            cell.senderLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        } else {
            
            cell.senderLabel.font = UIFont(name:"HelveticaNeue", size: 20.0)
            cell.sentImage.image = photoUtils.cropImageToSquare(image: UIImage(data : msg.imageData!)!)
        }
        cell.senderLabel.text = msg.user.displayName
        
        cell.sentDate.text = NSDateFormatter.localizedStringFromDate(msg.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        
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
    
    @IBAction func unwindToMessages(segue: UIStoryboardSegue) {
        
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "messageDetailSegue" {
            
            let destinationViewController = segue.destinationViewController as! MessageDetailVC
            destinationViewController.delegate = self
            let message = fetchedMessages[tableView.indexPathForSelectedRow!.row]


            destinationViewController.message = message
            destinationViewController.comingFrom = "MessageTableVC"
        }
        
        
    }
    
    


}
    



