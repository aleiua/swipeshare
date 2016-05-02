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
    
    var blockedUsers = [BlockedUser]()
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    //var fetchedMessages: [Message] = []
    
    var fetchedMessages: [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch blocked users for referencing when giving prompt
        let blockedUserFetchRequest = NSFetchRequest(entityName: "BlockedUser")
        
        do {
            blockedUsers = try managedContext.executeFetchRequest(blockedUserFetchRequest) as! [BlockedUser]
            print("going to print blocked users count")
            print(blockedUsers.count)
        } catch {
            print("error fetching blocked user list from CoreData")
        }
        
        // Create a new fetch request using the LogItem entity
        let messageFetchRequest = NSFetchRequest(entityName: "Message")
        print("Setting up fetch request")
        
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) // Puts newest messages on top
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        messageFetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            fetchedMessages = try managedContext.executeFetchRequest(messageFetchRequest) as! [Message]
            
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
    
    
    // FIGURE OUT DELETING FROM CORE DATAAAA
    // FIGURE OUT DELETING FROM CORE DATAAAA
    // FIGURE OUT DELETING FROM CORE DATAAAA
    // FIGURE OUT DELETING FROM CORE DATAAAA
    
    func deleteMessage() {
        self.tableView.deleteRowsAtIndexPaths([self.tableView.indexPathForSelectedRow!], withRowAnimation: UITableViewRowAnimation.Automatic)
        //messageManager.messages.removeAtIndex(self.tableView.indexPathForSelectedRow!.row)
    }

    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        
        // FIGURE OUT DELETING FROM CORE DATAAAA
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: " Delete ", handler:{action, indexpath in
            //self.messageManager.messages.removeAtIndex(indexPath.row)
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
        let msg = fetchedMessages[indexPath.row] as Message
        
        if msg.hasBeenOpened == false {
            cell.senderLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)

        } else {
            cell.senderLabel.font = UIFont(name:"HelveticaNeue", size: 20.0)
            cell.sentImage.image = self.cropImageToSquare(image: UIImage(data: msg.imageData!)!)
        }
        cell.senderLabel.text = String(msg.sender)
        
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
        }
    }
    
    
    func cropImageToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
        
    }

    
    


}
    



