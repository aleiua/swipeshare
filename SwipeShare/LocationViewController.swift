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
