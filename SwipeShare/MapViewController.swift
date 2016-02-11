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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        self.MapView.showsUserLocation = true
        self.MapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        
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
