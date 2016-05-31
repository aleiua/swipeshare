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
    
    var delegate: SettingsViewController? = nil

    
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isBeingDismissed() || self.isMovingFromParentViewController()) {
            delegate?.setupFriends()
        }
    }

    
    func getUserInfoFromParse(displayName: String) -> [PFObject] {
        print("getting user info from parse")
        let query = PFQuery(className:"_User")
        query.whereKey("name", containsString: displayName)
        
        print(displayName)
        
        var users = [PFObject]()
        do {
            try users = query.findObjects()
            
        }
            
            // Handle errors in getting pictures from parse
        catch {
            print("Error getting received users")
        }
        
        print("number found in parse")
        print(users.count)
        return users
        
        
    }
    
    func getProfPic(currUser: PFUser, sender: User) {
        if let picture = currUser["profilePicture"] as? PFFile {
            
            picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    
                    sender.profImageData = imageData
                    
                }
            }
        }
        // SAVING MANAGED OBJECT CONTEXT - SAVES USER TO CORE DATA
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }

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
            
            var existingUser = [User]()
            
            let checkForUserFetchRequest = NSFetchRequest(entityName: "User")
            // Create Predicate
            let checkPredicate = NSPredicate(format: "%K == %@", "displayName", cell!.textLabel!.text!)
            checkForUserFetchRequest.predicate = checkPredicate
            do {
                existingUser = try managedObjectContext.executeFetchRequest(checkForUserFetchRequest) as! [User]
                print("going to print friend count")
                print(existingUser.count)
            } catch {
                print("error fetching friend list from CoreData")
            }

            if existingUser.count == 0 {
                print("creating new sender")
                let user = getUserInfoFromParse(cell!.textLabel!.text!)
                    
                    print("hello")
                
                    let currUser = user[0] as! PFUser
                    let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext)

                    let sender = User(username: currUser["username"] as! String, displayName: currUser["name"] as! String, entity: userEntity!, insertIntoManagedObjectContext: self.managedObjectContext)

                    
                    sender.status = "friend"
                    

                    

                
                
            } else {
                existingUser[0].status = "friend"
            }
            
            // SAVING MANAGED OBJECT CONTEXT - SAVES USER TO CORE DATA
            do {
                try managedObjectContext.save()
                print("saving new friend")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            
            self.yawFriendSet.insert(cell!.textLabel!.text!)
            self.facebookFriends.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        
        var existingUser2 = [User]()
        
        let checkForUserFetchRequest2 = NSFetchRequest(entityName: "User")
    
        
            
            do {
                existingUser2 = try managedObjectContext.executeFetchRequest(checkForUserFetchRequest2) as! [User]
                print("going to print friend count2")
                print(existingUser2.count)
                
            } catch {
                print("error fetching friend list from CoreData")
            }

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
