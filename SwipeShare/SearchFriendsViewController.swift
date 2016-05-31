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

class SearchFriendsViewController: UITableViewController, UISearchBarDelegate {
    
    
    @IBOutlet var navBar: UINavigationItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var yawFriendSet = Set<String>()
    
    
    let cellIdentifier = "cell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    

    var searchActive : Bool = false

    var users:[String] = [String]()
    var filteredUsers:[String] = [String]()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        searchBar.delegate = self
        search()
        
    }
    
    
    func search(searchText: String? = nil){
        let query = PFQuery(className: "_User")
        if(searchText != nil){
            query.whereKey("name", containsString: searchText)
        }
        query.includeKey("sender")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            let data = results as [PFObject]!
            
            for item in data {
                let name = item["name"] as! String
                if (!self.yawFriendSet.contains(name)) {
                    self.users.append(name)
                }
            }
            
            print(self.users)
            self.tableView.reloadData()
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

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.characters.count == 0){
            searchActive = false
            tableView.reloadData()
            return
        } else {
            searchActive = true
        }
        
        
        // Make sure is start of a word not just a substring within a word
        filteredUsers = users.filter({ (text) -> Bool in
            
            let index = text.lowercaseString.rangeOfString(searchText.lowercaseString)
            if (index == nil) {
                return false
            }
            // Check first name
            let start = text.startIndex.distanceTo((index?.startIndex)!)
            if (start == 0) {
                return true
            }
            // Check for last name / middle name
            let i = text.startIndex.advancedBy(start - 1)
            if (text[i] == " ") {
                return true
            }
            
            return false
        })
    
        
        self.tableView.reloadData()
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive == true){
            return self.filteredUsers.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let name = self.filteredUsers[indexPath.row]
        cell.textLabel!.text = name
        
        cell.detailTextLabel!.font = UIFont.ioniconOfSize(20)
        cell.detailTextLabel!.text = String.ioniconWithCode("ion-ios-plus-empty")
        cell.detailTextLabel!.textColor = UIColor(red: 0.0/255.0, green: 200.0/255.0, blue: 80.0/255.0, alpha: 1.0)


        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if (indexPath.section == 0) {

            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.message.text = "Added \(cell!.textLabel!.text!)!"
            overlayView.displayView(view)
            
            self.yawFriendSet.insert(cell!.textLabel!.text!)
            
            self.filteredUsers.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            
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

        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        
//        if (indexPath.section == 0) {
//         
//            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
//            
//            let overlayView = OverlayView()
//            overlayView.message.text = "Added \(cell!.textLabel!.text!)!"
//            overlayView.displayView(view)
//            
//            
//            users = users.filter() {$0 != cell!.textLabel!.text!}
//            self.filteredUsers.removeAtIndex(indexPath.row)
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            
//        }
        
    }

    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
