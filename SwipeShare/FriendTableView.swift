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

class FriendTableView: UITableViewController {
    
    
    let cellIdentifier = "cell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // var users: [User] = [User]()
    var fetchedUsers: [User] = [User]()
    
    override func viewDidLoad() {
        print("yayfriendview")
        super.viewDidLoad()
        
        // Fetch messages from core Data, sorted by date
        let friendFetchRequest = NSFetchRequest(entityName: "User")
        //Creat Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "mostRecentCommunication", ascending: false) // Puts newest messages on top
        friendFetchRequest.sortDescriptors = [sortDescriptor]
        // Create Predicate
//        let friendPredicate = NSPredicate(format: "%K == %@", "status", "friend")
//        friendFetchRequest.predicate = friendPredicate
        
        do {
            fetchedUsers = try managedObjectContext.executeFetchRequest(friendFetchRequest) as! [User]
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
        
        print(fetchedUsers.count)
        return fetchedUsers.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellAtIndexPath(indexPath)
        
    }

    
    func cellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        let friend = fetchedUsers[indexPath.row] as User
        
        print(friend.displayName)

        cell!.textLabel!.text = friend.displayName
        
        if friend.status != nil {
            cell!.detailTextLabel!.text = friend.status
            print("user status:")
            print(friend.status)
        } else {
            print("no status")
        }
        return cell!
        
        
    }
    

}
