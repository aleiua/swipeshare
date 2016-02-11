//
//  LocationViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 1/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Foundation



class LocationViewController: ViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var nearbyLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    // Swipeable image
//    @IBOutlet weak var image: UIImageView!
    
    
    // Button for accessing photos
    @IBOutlet weak var photoz: UIButton!
    

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    
    var userObjectId = String()
    
    

    
    
    
    
    
    @IBAction func getCurrentLocation(sender: AnyObject) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    @IBAction func logout() {
        
        
        // Clean up user location information when they log out
        let user = PFUser.currentUser()
        user!["location"].deleteInBackground()
        
        
//        let query = PFQuery(className:"Location")
//        query.getObjectInBackgroundWithId(userObjectId) {
//            
//            (location : PFObject?, error: NSError?) -> Void in
//            if error != nil {
//                print(error)
//            } else if let location = location {
//                print("deleting shit")
//                location.deleteInBackground()
//            }
//        }
//        
        // Log em out
        PFUser.logOut()
        

        // Send back to login screen
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    
    @IBAction func openPhotos(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
            let selectedImage : UIImage = image
            print(selectedImage)
        }
    }
  
    
    
    /*
    * Enables swiping of IBOutlet image
    */
//    func initializeGestureRecognizer()
//    {
//        //For PanGesture Recoginzation
//        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("recognizePanGesture:"))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 1
//        image.addGestureRecognizer(panGesture)
//    }
    
    
    
    override func viewDidLoad()  {
        
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation        
        
        let user = PFUser.currentUser()
//        user!["location"] = PFGeoPoint()
        
//        usernameLabel.text = user?.username
        
        let l = PFObject(className:"Location")
        
        l["latitude"] = Double()
        l["longitude"] = Double()
        if user == nil {
            l["user"] = NSNull()
        }
        else {
            l["user"] = user
        }
        
        l.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.userObjectId = l.objectId!
                print(self.userObjectId)
            }
        }

    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }
    

    

    /*
    * Update longitude/latitude locations
    */
    func locationManager(manager:CLLocationManager, didUpdateLocations locations: Array <CLLocation>) throws {
        
        print("Updating locations")
        
        currentLocation = locationManager.location!
        latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        longitudeLabel.text = "\(currentLocation.coordinate.longitude)"

        let query = PFQuery(className:"Location")
        
        query.getObjectInBackgroundWithId(userObjectId) {
            
            (location : PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let location = location {
                location["latitude"] = self.currentLocation.coordinate.latitude
                location["longitude"] = self.currentLocation.coordinate.longitude
                location.saveInBackground()
            }
        }

        
    }
    
    
    
    /*
    * Update displayed heading
    */
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        print("Heading updating")
        currentHeading = locationManager.heading!
        headingLabel.text = "\(currentHeading.trueHeading)"

//        print("\(currentHeading.trueHeading)")
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
