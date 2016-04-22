//
//  MessageDetailVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/6/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Parse

class MessageDetailVC: UIViewController{
    
    
    var message: Message!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    @IBOutlet weak var messageNavBar: UINavigationItem!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func savePhoto(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(messageImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = false
        self.navigationController!.hidesBarsOnTap = true
        messageNavBar.title = String(message.sender)
        if message.imageData == nil{
         getPhoto()
            
        } else {
            messageImageView?.image = UIImage(data: message.imageData!)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.toolbarHidden = true
        self.navigationController!.hidesBarsOnTap = false
    }
    
    func getPhoto(){
        let query = PFQuery(className: "sentPicture")
        query.getObjectInBackgroundWithId(self.message.objectId){
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                
                if let picture = object!["image"] as? PFFile {
                    
                    picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            print("Photo downloaded")
                            self.message.imageData = imageData
                            self.messageImageView.image = UIImage(data: self.message.imageData!)
                            self.activityIndicator.stopAnimating()
                            // Set object to read.
                            object!["hasBeenRead"] = true
                            object!.saveInBackground()
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                fatalError("Failure to save context: \(error)")
                            }
                        }
                        else {
                            print("Error getting image data")
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                }
                
                
                
            }
            else {
                print(error)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "The image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "sendAgainSegue" {
            
            let destinationViewController = segue.destinationViewController as! LocationViewController
            
            // Look at how we are trying to pass the immage
            destinationViewController.image = messageImageView
            
            
        }
    }
    
}
