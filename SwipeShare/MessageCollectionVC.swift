//
//  MessageCollectionVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 5/15/16.
//  Copyright © 2016 yaw. All rights reserved.
//


import Foundation


import UIKit
import Parse
import CoreData

class MessageCollectionVC: UICollectionViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var delegate: ConversationMessageTVC? = nil

    let imageCellIdentifier = "imageCell"
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let photoUtils = Utilities()

    
    // var users: [User] = [User]()
    var fetchedMessages: [Message] = [Message]()
    var user: User?
    
    var selectedCell: NSIndexPath!

    
    var passingMessage: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if user == nil {
            print("we have a problem")
        }
        
        
        fetchedMessages = user!.messages.allObjects as! [Message]
        
        self.title = String(user!.displayName)

        collectionView!.reloadData()
        
    }
    

    //Use for size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        

        let size = CGSize(width: 100, height: 100)
        return size
    }
    
    //Use for interspacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedMessages.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return imageCellAtIndexPath(indexPath)
        
    }
    
    
    
    func imageCellAtIndexPath(indexPath: NSIndexPath) -> ImageCell {
        
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier(imageCellIdentifier, forIndexPath: indexPath) as! ImageCell
        let message = fetchedMessages[indexPath.row] as Message
        
        if message.hasBeenOpened {
            let image = UIImage(data : message.imageData!)
            let croppedImage = photoUtils.cropImageToSquare(image: image!)
            cell.sentImage.image = croppedImage
        } else {
            cell.sentImage.contentMode = .ScaleAspectFit
            
            cell.sentImage.image = UIImage(named : "QuestionMark")

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
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
//            selectedCell = indexPath as NSIndexPath
//     
//            performSegueWithIdentifier("convoMessageDetailSegue", sender: cell)
//        } else {
//            // Error indexPath is not on screen: this should never happen.
//        }
    }
    
    // MARK: - Navigation
    
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "convoMessageDetailSegue" {
            
            
            let destinationViewController = segue.destinationViewController as! MessageDetailVC
            let cell = sender as! ImageCell
            let indexPath = self.collectionView!.indexPathForCell(cell)
            
            passingMessage = self.fetchedMessages[indexPath!.row] as Message

            destinationViewController.message = passingMessage
            destinationViewController.comingFrom = "MessageCollectionVC"
            
        }
    }
    
    
    
    
}




