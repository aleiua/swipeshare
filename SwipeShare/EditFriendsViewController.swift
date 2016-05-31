//
//  FriendTableView.swift
//  SwipeShare
//
//  Created by A. Lynn on 5/5/16.
//  Copyright © 2016 yaw. All rights reserved.
//
import Foundation
import CoreData
import UIKit

class EditFriendsViewController: UITableViewController {
    
    
    @IBOutlet var navBar: UINavigationItem!
    var delegate: SettingsViewController? = nil

    
    let cellIdentifier = "cell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // var users: [User] = [User]()
    var yawFriends = [User]()
    var blockedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 55.0
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isBeingDismissed() || self.isMovingFromParentViewController()) {
            delegate?.setupFriends()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Friends"
        }
        else if (section == 1) {
            return "Blocked Users"
        }
        return nil
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return yawFriends.count
        }
        else if section == 1 {
            return blockedUsers.count
        }

        return 0
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellAtIndexPath(indexPath)
        
    }
    

    
    func cellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if (indexPath.section == 0) {
            cell!.textLabel!.text = yawFriends[indexPath.row].displayName
            cell!.detailTextLabel!.text = "Remove Friend"
            cell!.detailTextLabel!.textColor = UIColor.redColor()
        }
        else if (indexPath.section == 1) {
            cell!.textLabel!.text = blockedUsers[indexPath.row].displayName
            cell!.detailTextLabel!.text = "Unblock"
            cell!.detailTextLabel!.textColor = UIColor.blueColor()
        }
        return cell!
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)

        // UNFRIEND
        if (indexPath.section == 0) {
            // Friends and Distance
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.message.text = "Removed \(cell!.textLabel!.text!) from friends"
            overlayView.displayView(view)
            
            yawFriends[indexPath.row].status = nil
            self.yawFriends.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        }
        // UNBLOCK
        else if (indexPath.section == 1) {
            
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.message.text = "Unblocked \(cell!.textLabel!.text!)"
            overlayView.displayView(view)
            
            blockedUsers[indexPath.row].status = nil
            self.blockedUsers.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        // SAVING MANAGED OBJECT CONTEXT - SAVES USER TO CORE DATA
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }

    

}
