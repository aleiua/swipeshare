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
    
    
    let cellIdentifier = "cell"
    //let messageManager = MessageManager.sharedMessageManager
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    

    var searchActive : Bool = false

    var users:[String] = [String]()
    var filtered:[String] = [String]()

    
    
    
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
                self.users.append(item["name"] as! String)
            }
            print(self.users)
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
            return
        } else {
            searchActive = true
        }
        
        
        // Make sure is start of a word not just a substring within a word
        filtered = users.filter({ (text) -> Bool in
            
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
            return self.filtered.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let name = self.filtered[indexPath.row]
        cell.textLabel!.text = name
        
        cell.detailTextLabel!.font = UIFont.ioniconOfSize(20)
        cell.detailTextLabel!.text = String.ioniconWithCode("ion-ios-plus-empty")

        
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
