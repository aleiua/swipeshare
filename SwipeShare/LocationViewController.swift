//
//  LocationViewController.swift
//  SwipeShare
//
//  Created by A. Lynn on 1/24/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import CoreLocation



class LocationViewController: ViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
//    @IBOutlet weak var imageG: UIImageView!
    
    @IBOutlet weak var photoz: UIButton!
    
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    
    
    
    
    
    @IBAction func getCurrentLocation(sender: AnyObject) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
    }
    
    @IBAction func openPhotos(picker: UIImagePickerController){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
//    func initializeGestureRecognizer()
//    {
//        //For PanGesture Recoginzation
//        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("recognizePanGesture:"))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 1
//        imageG.addGestureRecognizer(panGesture)
//    }
    
    /*
    * Performs updating on objects to which the gesture recognizer is added
    *
    */
//    func recognizePanGesture(sender: UIPanGestureRecognizer)
//    {
//        let translate = sender.translationInView(self.view)
//        sender.view!.center = CGPoint(x:sender.view!.center.x + translate.x,
//            y:sender.view!.center.y + translate.y)
//        sender.setTranslation(CGPointZero, inView: self.view)
    
        // need to store first and last locations of swipe and calculate angle relative to top of screen
        
        
        // Mess with this to make deceleration look natural
//        if sender.state == UIGestureRecognizerState.Ended {
//            // 1
//            let velocity = sender.velocityInView(self.view)
//            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
//            let slideMultiplier = magnitude / 200
//            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
//            
//            // 2
//            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
//            // 3
//            var finalPoint = CGPoint(x:sender.view!.center.x + (velocity.x * slideFactor),
//                y:sender.view!.center.y + (velocity.y * slideFactor))
//            // 4
//            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
//            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
//            
//            // 5
//            UIView.animateWithDuration(Double(slideFactor * 2),
//                delay: 0,
//                // 6
//                options: UIViewAnimationOptions.CurveEaseOut,
//                animations: {sender.view!.center = finalPoint },
//                completion: nil)
//        }
//    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
//        self.initializeGestureRecognizer()
        


        // Do any additional setup after loading the view.
        
    }
    

    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)

        
    }
    
    

    func locationManager(manager:CLLocationManager, didUpdateLocations locations: Array <CLLocation>) {
        
        currentLocation = locationManager.location!
        latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
//        print("\(currentLocation.coordinate.latitude)")

//        print("\(currentLocation.coordinate.longitude)")


    }
    
    
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
