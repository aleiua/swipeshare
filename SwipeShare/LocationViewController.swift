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
    
    // Swipeable image
//    @IBOutlet weak var image: UIImageView!
    
    
    // Button for accessing photos
    @IBOutlet weak var photoz: UIButton!
    
    
    let earthRadius = 6378.137
    // distance of search in km
    let searchDistance = 0.1
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    
    var userObjectId = String()
    var userLatitude = Double()
    var userLongitude = Double()
    
    
    
    
    
    @IBAction func getCurrentLocation(sender: AnyObject) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
    }
    
    @IBAction func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    @IBAction func findNeighbors(sender: AnyObject) {
        
        print("Querying for neighbors")
        let query = PFQuery(className:"Location")
        query.whereKey("latitude",
            greaterThan: (userLatitude - searchDistance))
        query.whereKey("latitude",
            lessThan: (userLatitude + searchDistance))
        query.whereKey("longitude",
            greaterThan: (userLongitude - searchDistance))
        query.whereKey("longitude",
            lessThan: (userLongitude + searchDistance))
        
        query.findObjectsInBackgroundWithBlock {
             (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("No error. Printing neighbors")
                if let objects = objects {
                    for object in objects {
                        print(object["user"]["username"])
                    }
                }
            }
            else {
                print("Error querying neighbors")
            }
        }
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
        locationManager.distanceFilter = 5
        
        
        let user = PFUser.currentUser()
        let l = PFObject(className:"Location")
        
       
        l["latitude"] = Double()
        l["longitude"] = Double()
        if user == nil {
        l["user"] = NSNull()
        }
        else {
            l["user"] = user
        }
        
        //print(userObjectId)
        
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
    * Compute longitude at given distance away with same latitude
    */
    func maxLongitude(distance:Double, userLatitude:Double, userLongitude:Double) -> Double {
        // Convert degrees to radians
        let radLatitude = userLatitude * (M_PI/180)
        let radLongitude = userLongitude * (M_PI/180)
        
        let a = distance/(2*earthRadius)
        
        return (2 * asin(sqrt((sin(a)*sin(a))/(cos(radLatitude)*cos(radLatitude)))) + radLongitude)/(M_PI/180)
    }
    
    
    /*
    * Compute latitude at given distance away with same longitude
    */
    func maxLatitude(distance:Double, userLatitude:Double, userLongitude:Double) -> Double {
        
        // Convert degrees to radians
        let radLatitude = userLatitude * (M_PI/180)
        
        let a = distance/(2*earthRadius)
        
        return (2 * asin(sqrt((sin(a)*sin(a)))) + radLatitude)/(M_PI/180)
    }
    
    
    
    

    /*
    * Update longitude/latitude locations
    */
    func locationManager(manager:CLLocationManager, didUpdateLocations locations: Array <CLLocation>) {
        
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
                
                self.userLatitude = self.currentLocation.coordinate.latitude
                self.userLongitude = self.currentLocation.coordinate.longitude
                
                location.saveInBackground()
            }
        }

        
        
        
//        print("\(currentLocation.coordinate.latitude)")
//        print("\(currentLocation.coordinate.longitude)")
    }
    
    
    
    /*
    * Update displayed heading
    */
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
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
