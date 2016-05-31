//
//  ConversationMessageTVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 5/15/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation


import UIKit
import Parse
import CoreData

class ConversationMessageTVC: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    let photoUtils = Utilities()
    
    let cellIdentifier = "UserCell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // var users: [User] = [User]()
    var fetchedConversations: [User] = [User]()

    let locView = LocationViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Conversations"
        
        getMessagesFromCore()
        
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(MessageTableVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
 
    }
    
    func getMessagesFromCore() {
        // Fetch messages from core Data, sorted by date
        let conversationFetchRequest = NSFetchRequest(entityName: "User")
        conversationFetchRequest.predicate = NSPredicate(format: "%K != %@", "username", "currentUser")
        let sortDescriptor = NSSortDescriptor(key: "mostRecentCommunication", ascending: false) // Puts newest messages on top
        conversationFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            fetchedConversations = try managedContext.executeFetchRequest(conversationFetchRequest) as! [User]
        } catch {
            fatalError("Failed to fetch conversations: \(error)")
        }
    }
    
    
    func getDataFromParse() {
        let locationViewCont = LocationViewController()
        
        locationViewCont.getPictureObjectsFromParse()
        print("trying to get data from Parse")
        
        
    }

    
    @IBAction func refresh(sender: AnyObject) {
        
        self.getDataFromParse()
        
        self.getMessagesFromCore()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
    }

    
    
    // Makes sure tab bar navbar doesn't overlap.
    override func viewDidLayoutSubviews() {
        if (self.navigationController?.navigationBar.frame) != nil {

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
        return fetchedConversations.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return userCellAtIndexPath(indexPath)
        
    }
    


    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    
    func deleteMessage() {
        self.tableView.deleteRowsAtIndexPaths([self.tableView.indexPathForSelectedRow!], withRowAnimation: UITableViewRowAnimation.Automatic)
        //messageManager.messages.removeAtIndex(self.tableView.indexPathForSelectedRow!.row)
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! UserCell

        
        
        let blockAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: " Block User ", handler:{action, indexpath in
            //self.messageManager.messages.removeAtIndex(indexPath.row)
            let overlayView = OverlayView()
            overlayView.message.text = "You blocked \(cell.usernameLabel!.text!)"
            overlayView.displayView(self.view)
            
            
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        });
        blockAction.backgroundColor = UIColor.init(red: 240.0/255.0, green: 0/255.0, blue: 20/255.0, alpha: 1.0)
        
        return [blockAction]
    }
    
    //empty implementation
    //    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //    }
    
    /*************/
    
    
    
    func userCellAtIndexPath(indexPath: NSIndexPath) -> UserCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserCell
        let convo = fetchedConversations[indexPath.row] as User
        
        cell.usernameLabel.font = UIFont(name:"HelveticaNeue", size: 20.0)
        
        cell.usernameLabel.text = convo.displayName
        
        cell.sentDate.text = NSDateFormatter.localizedStringFromDate(convo.mostRecentCommunication, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        
        if convo.profImageData != nil {
            cell.profilePictureThumbnail.image = self.photoUtils.cropImageToSquare(image: UIImage(data : convo.profImageData!)!)
        } else {
            // Needs to be updated with default
            cell.profilePictureThumbnail.image = photoUtils.cropImageToSquare(image: UIImage(named: "QuestionMark")!)
            print("no prof pic")
        }
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
        
        if segue.identifier == "convoDetailSegue" {
            
            locView.getPictureObjectsFromParse()
            
            let destinationViewController = segue.destinationViewController as! MessageCollectionVC
            destinationViewController.delegate = self

            let user = fetchedConversations[tableView.indexPathForSelectedRow!.row]
            print(user.displayName)
            
            destinationViewController.user = user
            
            print(destinationViewController.user?.displayName)
            
        }
    }
    
    
    
    
}




