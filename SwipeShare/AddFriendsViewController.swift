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

    

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row: \(indexPath.row)")
        print("Section: \(indexPath.section)")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if (indexPath.section == 0) {
            // Friends and Distance
        }
        else if (indexPath.section == 1) {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            print(cell!.textLabel!.text!)
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
            cell!.detailTextLabel!.text = String.ioniconWithCode("ion-ios-arrow-right")
            
        }
        else {

        
            cell!.textLabel!.text = facebookFriends[indexPath.row]
            
            cell!.detailTextLabel!.font = UIFont.ioniconOfSize(20)
            cell!.detailTextLabel!.text = String.ioniconWithCode("ion-ios-plus-empty")
        }
        
//        if friend.status != nil {
//            cell!.detailTextLabel!.text = friend.status
//            print("user status:")
//            print(friend.status)
//        } else {
//            print("no status")
//        }
        return cell!
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
