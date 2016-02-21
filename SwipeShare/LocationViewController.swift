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
import Darwin



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
    
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    
    var userObjectId = String()
    var userLatitude = Double()
    var userLongitude = Double()
    
    
    /*
    Rough Distances:
    .1 = 11km
    .01 = 1km = 1000m
    .001 = .1km = 100m
    .0001 = .01km = 10m
    
    */
    var searchDistance = 0.0001
    var earthRadius = 6371.0
    
    
    
    @IBAction func getCurrentLocation(sender: AnyObject) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
    }
    
    // Calculates distance from point A to B using Haversine formula
    // Currently returns distance in KM
    func Haversine(latA : Double, lonA : Double, latB : Double, lonB : Double) -> Double {
        // Convert to radians
        let conversionFactor = M_PI / 180
        let phiA = latA * conversionFactor
        let phiB = latB * conversionFactor
        
        let deltaPhi = (latB - latA) * conversionFactor
        let deltaLamba = (lonB - lonA) * conversionFactor
        
        let a = sin(deltaPhi / 2) * sin(deltaPhi / 2) + cos(phiA) * cos(phiB)
            * sin(deltaLamba / 2) * sin(deltaLamba / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = earthRadius * c
        
        return d
        
    }
    
    // Calculates bearing from point A to point B.
    // Currently returns in degrees.
    func Bearing(latA : Double, lonA : Double, latB : Double, lonB : Double) -> Double {
        let conversionFactor = M_PI / 180
        let phiA = latA * conversionFactor
        let phiB = latB * conversionFactor
        
        let deltaLamba = (lonB - lonA) * conversionFactor
        
        let y = sin(deltaLamba) * cos(phiB)
        let x = cos(phiA) * sin(phiB) - sin(phiA) * cos(phiB) * cos(deltaLamba)
        
        let b = atan2(y, x)
        
        return b * (180 / M_PI)
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
        let query = PFQuery(className:"_User")
        query.whereKey("latitude",
            greaterThan: (userLatitude - searchDistance))
        query.whereKey("latitude",
            lessThan: (userLatitude + searchDistance))
        query.whereKey("longitude",
            greaterThan: (userLongitude - searchDistance))
        query.whereKey("longitude",
            lessThan: (userLongitude + searchDistance))
        
        query.findObjectsInBackgroundWithBlock {
             (users: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("No error. Printing neighbors")
                if let users = users {
                    var iter = 1
                    for user in users {
                        if (user.objectId != self.userObjectId) {
                            print("Adjacent User No:" + String(iter))
                            print(user["username"])
                            iter++

                            let toSend = PFObject(className: "sentObject")
                            toSend["message"] = "What up, badBitch"
                            toSend["date"] = NSDate()
                        
                            let currUser = PFUser.currentUser()
                            toSend["sender"] = currUser
                            toSend["recipient"] = user
                            
                            toSend.saveInBackgroundWithBlock { (success, error) -> Void in
                                if success {
                                    print("Saved toSend object.")
                                }
                                else {
                                    print("Failed saving toSend object")
                                }
                            }

                            
                        }
                        
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
        
        print("Running Haversine")
        let distance = Haversine(40.7486, lonA: -73.9864, latB : 42.7486, lonB : -75.9864)
        print("Distance: \(distance)")
        let bearing = Bearing(40.7486, lonA: -73.9864, latB : 42.7486, lonB : -75.9864)
        print("Bearing:  \(bearing)")
        
        let user = PFUser.currentUser()
        if user == nil {
            print("Could not get current User")
        }
        else {
            user!["latitude"] = Double()
            user!["longitude"] = Double()
        }
        
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.userObjectId = user!.objectId!
                print(self.userObjectId)
            }
        }

        
        
        

        
        
        
        
//        let l = PFObject(className:"Location")
//       
//        l["latitude"] = Double()
//        l["longitude"] = Double()
        
//        if user == nil {
//            l["user"] = NSNull()
//        }
//        else {
//            l["user"] = user
//        }
        
//        l.saveInBackgroundWithBlock { (success, error) -> Void in
//            if success {
//                self.userObjectId = l.objectId!
//                print(self.userObjectId)
//            }
//        }
    }
    

    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }
    
    

    
    

    /*
    * Update longitude/latitude locations
    */
    func locationManager(manager:CLLocationManager, didUpdateLocations locations: Array <CLLocation>) {
        
        currentLocation = locationManager.location!

        
        
        latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
        
        let user = PFUser.currentUser()
        
        if user == nil {
            print("Could not get current User")
        }
        else {
            user!["latitude"] = self.currentLocation.coordinate.latitude
            user!["longitude"] = self.currentLocation.coordinate.longitude
        }
        
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Saved Successfully")
                self.userLatitude = self.currentLocation.coordinate.latitude
                self.userLongitude = self.currentLocation.coordinate.longitude
            }
        }
    }
    
    
    
    /*
    * Update displayed heading
    */
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        currentHeading = locationManager.heading!
        headingLabel.text = "\(currentHeading.trueHeading)"
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
