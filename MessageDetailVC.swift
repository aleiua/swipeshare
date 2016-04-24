//
//  MessageDetailVC.swift
//  SwipeShare
//
//  Created by A. Lynn on 3/6/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

import UIKit
import Parse

class MessageDetailVC: UIViewController, UIScrollViewDelegate{
    
    
    var message: Message!
    
    
    @IBOutlet weak var messageNavBar: UINavigationItem!
    @IBOutlet weak var messageImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func savePhoto(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(messageImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return self.imageView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = false
        self.navigationController!.hidesBarsOnTap = true
        messageNavBar.title = String(message.sender["username"])
        let date = NSDateFormatter.localizedStringFromDate(message.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
         messageNavBar.rightBarButtonItem?.title = date
        if message.image == nil{
         getPhoto()
        }
        else {
            self.activityIndicator.stopAnimating()
        }
        messageImageView?.image = message.image
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.toolbarHidden = true
        self.navigationController!.hidesBarsOnTap = false
    }
    
    func getPhoto(){
        let query = PFQuery(className: "sentPicture")
        query.getObjectInBackgroundWithId(self.message.id){
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                
                if let picture = object!["image"] as? PFFile {
                    
                    picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            print("Photo downloaded")
                            self.message.image = UIImage(data:imageData!)
                            self.messageImageView.image = self.message.image
                            self.activityIndicator.stopAnimating()
                            // Set object to read.
                            object!["hasBeenRead"] = true
                            object!.saveInBackground()
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
            
            destinationViewController.image = messageImageView
            
            
        }
    }
    
}
