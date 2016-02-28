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
    
<<<<<<< HEAD
    // Button for accessing photos
    @IBOutlet weak var photoz: UIButton!
    
    @IBOutlet weak var userLabel: UILabel!
    
=======
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
    

>>>>>>> master
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
    
<<<<<<< HEAD
    */
    var searchDistance = 0.0001
    var earthRadius = 6371.0
=======

    
    
>>>>>>> master
    
    
    
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
        
        
        // Get all close neighbors
        var users = []
        var index = -1
        do {
            try users = query.findObjects()
            for (i, user) in users.enumerate() {
                if (user.objectId != self.userObjectId) {
                    print("Adjacent User: " + String(user["username"]))
                }
                else {
                    index = i
                }
            }
        }
        catch {
            print("Error getting neighbors!")
        }
        
        // Send to first neighbor in return array.
        //        print(users)
        
        for (i, recipient) in users.enumerate() {
            print("____________________")
            print("Recipient: " + String(recipient.objectId))
            print("Current: " + self.userObjectId)
            
            if (i != index) {
                
                let toSend = PFObject(className: "sentObject")
                toSend["message"] = "What up, badBitch"
                toSend["date"] = NSDate()
                
                let sender = PFUser.currentUser()
                toSend["sender"] = sender
                
                let recipient = users[0]
                
                
                print("Only sending to: " + String(recipient["username"]))
                toSend["recipient"] = recipient
                
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

    
    override func viewDidLoad()  {
        
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        // locationManager.distanceFilter = 5
        
        print("Running Haversine")
        let distance = Haversine(40.7486, lonA: -73.9864, latB : 42.7486, lonB : -75.9864)
        print("Distance: \(distance)")
        let bearing = Bearing(40.7486, lonA: -73.9864, latB : 42.7486, lonB : -75.9864)
        print("Bearing:  \(bearing)")
        
        let user = PFUser.currentUser()
<<<<<<< HEAD
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
    }
=======
        user!["location"] = PFGeoPoint()
        
        user!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("Location has been saved.")
                print(user)
            }
            else {
                print("Location was not saved!")
            }
        }
    }
//
//        usernameLabel.text = user?.username
//        
//        let l = PFObject(className:"Location")
//        
//        l["latitude"] = Double()
//        l["longitude"] = Double()
//        if user == nil {
//        l["user"] = NSNull()
//        }
//        else {
//            l["user"] = user
//        }
//        
//        //print(userObjectId)
//        
//        l.saveInBackgroundWithBlock { (success, error) -> Void in
//            if success {
//                self.userObjectId = l.objectId!
//                print(self.userObjectId)
//            }
//        }

        
        
        
        
        
        
        // To enable swiping:
//        self.initializeGestureRecognizer()
        
        // Testing Parse
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            print("Object has been saved.")
//        }
//        
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
//            if error == nil {
//                let user = PFUser.currentUser()
//                user!["location"] = geoPoint
//                user!.saveInBackgroundWithBlock {
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        // The object has been saved.
//                        print("Location has been saved.")
//                        print(user)
            
//                        let userGeoPoint = user!["location"] as! PFGeoPoint
//                        let query = PFUser.query()
//                        query!.whereKey("location", nearGeoPoint:userGeoPoint)
//                        query!.findObjectsInBackgroundWithBlock {
//                            (nearbies: [PFObject]?, error: NSError?) -> Void in
//                            if error == nil {
//                                 print("Successfully retrieved \(nearbies!.count) nearby users.")
//                                var nearbyText = ""
//                                for object in nearbies! {
//                                    if object.objectId != user?.objectId {
//                                        let name = object.objectForKey("username") as! String;
//                                        if nearbyText.isEmpty {
//                                            nearbyText = name
//                                        } else {
//                                            nearbyText += ", \(name)"
//                                        }
//                                    }
////                                    print(object)
//                                }
//                                self.nearbyLabel.text = nearbyText
//                            }
//                        }
//                        
//                        let userGeoPoint = user!["location"] as! PFGeoPoint
//                        let query = PFUser.query()
//                        query!.whereKey("location", nearGeoPoint:userGeoPoint)
//                        query!.limit = 10
//                        let nearbies = query!.findObjects()
//                            for object in nearbies {
//                                print(object)
//                            }
//                        self.nearbyLabel.text = "\(nearbies[0].username)"
//                    
//                    } else {
//                        print("Location has NOT been saved.")
//                        // There was a problem, check error.description
//                    }
//                }
//                
//            }
//            else {
//                print("Could not get location in parse")
//            }
//        }
//        
//    }
>>>>>>> master
    

    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }
    
<<<<<<< HEAD
    

    
=======

>>>>>>> master
    

    /*
    * Update longitude/latitude locations
    */
    func locationManager(manager:CLLocationManager, didUpdateLocations locations: Array <CLLocation>) throws {
        
        print("In Update")
        currentLocation = locationManager.location!
<<<<<<< HEAD

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
=======
        
        latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
        
        let user = PFUser.currentUser()! as PFUser
        
        let location = user["location"]! as! PFGeoPoint
        print(location.latitude)
        location.latitude = self.currentLocation.coordinate.latitude
        location.longitude = self.currentLocation.coordinate.longitude
        print(location.latitude)
        
        try user.save()
        
        
        //let query = PFQuery(className:"Location")
        
        
//        query.getObjectInBackgroundWithId(userObjectId) {
//            
//            (location : PFObject?, error: NSError?) -> Void in
//            if error != nil {
//                print(error)
//            } else if let location = location {
//                location["latitude"] = self.currentLocation.coordinate.latitude
//                location["longitude"] = self.currentLocation.coordinate.longitude
//                location.saveInBackground()
//            }
//        }

        
>>>>>>> master
    }
    
    
    
    /*
    * Update displayed heading
    */
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        currentHeading = locationManager.heading!
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
