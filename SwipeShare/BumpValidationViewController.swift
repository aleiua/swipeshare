//
//  CheckListViewController.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 4/7/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import Parse
import CoreData

class BumpValidationViewController: UIViewController {
    var recipient = [PFObject]()
    var delegate: LocationViewController? = nil
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var blurredBackgroundView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var yesButton: UIButton!

    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    
    @IBAction func sendMessage(sender: AnyObject) {
        delegate?.sendToUsers(recipient, bluetooth: true)
        delegate?.refreshSymbol()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEditing(true, animated: true)
        navBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        let name = recipient[0]["name"]
        navBar.topItem!.title = "Send photo to \(name)?"
        
        
        // Query Core Data for Profile Picture
        var fetchedUser: [User] = [User]()


        let bumpFetchRequest = NSFetchRequest(entityName: "User")
        let username = recipient[0]["username"] as! String
        print("Username: \(username)")
        let predicate = NSPredicate(format: "username == %@", username)
        bumpFetchRequest.predicate = predicate
        
        

        do {
            fetchedUser = try managedContext.executeFetchRequest(bumpFetchRequest) as! [User]
            if (fetchedUser.count > 0) {
                let firstUser = fetchedUser[0]

                if firstUser.profImageData != nil {
                    let imageRepresenation = UIImage(data : firstUser.profImageData!)
                    
                    let settingsController = SettingsViewController()
                    let squareImage = settingsController.cropImageToSquare(image: imageRepresenation!)
                    
                    userProfilePicture.image = squareImage
                }
            }

            

            
        } catch {
            fatalError("Failed to fetch user for bump screen: \(error)")
        }
        
        userProfilePicture.layer.borderWidth = 2
        userProfilePicture.layer.masksToBounds = false
        userProfilePicture.layer.borderColor = UIColor.grayColor().CGColor
        userProfilePicture.layer.cornerRadius = userProfilePicture.frame.height/2
        userProfilePicture.clipsToBounds = true


        
        
        //        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.effect as! UIBlurEffect)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
