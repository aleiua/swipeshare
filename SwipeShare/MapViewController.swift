//
//  MapViewController.swift
//  SwipeShare
//
//  Created by R. Neuhaus on 1/31/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import MapKit


class MapViewController: ViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var MapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    func getLocations() {
        var annotations:Array = [UserPoint]()
        
        let user = PFUser.currentUser()
        let userGeoPoint = user!["location"] as! PFGeoPoint
        let query = PFUser.query()
        
        query!.whereKey("location", nearGeoPoint:userGeoPoint)
        query!.findObjectsInBackgroundWithBlock {
            (nearbies: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(nearbies!.count) nearby users.")
                
                for object in nearbies! {
                    if object.objectId != user?.objectId {
                        let lat = object.objectForKey("location")!.latitude as Double
                        let long = object.objectForKey("location")!.longitude as Double
                        let annotation = UserPoint(latitude: lat, longitude: long)
                        annotation.title = object.objectForKey("username") as? String;
                        annotations.append(annotation)
                    }
                }
//                print(annotations)
                self.MapView.addAnnotations(annotations)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        self.MapView.showsUserLocation = true
        self.MapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        getLocations()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func TrackButton(sender: AnyObject) {
        self.MapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
    }
    
    // Location delegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last
//        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        self.MapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
}
