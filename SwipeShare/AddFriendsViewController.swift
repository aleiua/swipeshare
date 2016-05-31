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

class AddFriendsViewController: UITableViewController {
    
    
    @IBOutlet var navBar: UINavigationItem!
    
    let maxFriends = 10
    
    let cellIdentifier = "cell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // var users: [User] = [User]()
    var fetchedUsers: [User] = [User]()
    
    var facebookFriends = [String]()
    var yawFriendSet = Set<String>()



    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 55.0

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if (indexPath.section == 0) {
            // Friends and Distance
            performSegueWithIdentifier("toSearchFriends", sender: nil)
        }
        else if (indexPath.section == 1) {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.message.text = "Added \(cell!.textLabel!.text!)!"
            overlayView.displayView(view)

            
            self.yawFriendSet.insert(cell!.textLabel!.text!)
            self.facebookFriends.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
    }

    
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (section == 0) {
//            return 1
//        }
//        return 32
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return nil
        }
        else if (section == 1) {
            return "Facebook Friends"
        }
        return nil
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 2
    }
   
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else {
            return facebookFriends.count

        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellAtIndexPath(indexPath)
        
    }
    
    
    func cellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if (indexPath.section == 0) {
            cell!.textLabel!.text = "Add Friends by Name"
            
            cell!.detailTextLabel!.font = UIFont.ioniconOfSize(20)
            cell!.detailTextLabel!.text = String.ioniconWithCode("ion-ios-arrow-forward")
            cell!.detailTextLabel!.textColor = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 0.0/255.0, alpha: 0.75)
            
        }
        else {

        
            cell!.textLabel!.text = facebookFriends[indexPath.row]
            
            cell!.detailTextLabel!.font = UIFont.ioniconOfSize(20)
            cell!.detailTextLabel!.text = String.ioniconWithCode("ion-ios-plus-empty")
            cell!.detailTextLabel!.textColor = UIColor(red: 0.0/255.0, green: 200.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        }
        
        return cell!
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        if segue.identifier == "toSearchFriends" {
            
            let destination = segue.destinationViewController as! SearchFriendsViewController
            destination.yawFriendSet = self.yawFriendSet
            
        }
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
