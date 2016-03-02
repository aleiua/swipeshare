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
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var sendAnother: UIButton!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var nearestLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    
    var userObjectId = String()
    var userLatitude = Double()
    var userLongitude = Double()
    
    var angle: CGFloat!
    var panGesture: UIPanGestureRecognizer!
    
    
    var image: UIImageView!
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    
    var swipedHeading = Float()
    var DEBUG = true
   
    
    /*
    Rough Distances:
    .1 = 11km
    .01 = 1km = 1000m
    .001 = .1km = 100m
    .0001 = .01km = 10m
    */
    var searchDistance = 0.001
    var earthRadius = 6371.0
    
   /*****************************GESTURE HANDLING********************************/
    
    /*
    * Initialize panGestureRecognizer
    */
    func initializeGestureRecognizer() {
        //For PanGesture Recoginzation
        panGesture = UIPanGestureRecognizer(target: self, action: Selector("recognizePanGesture:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
    }
    
    /*
    * Performs updating on objects to which the gesture recognizer is added
    *
    */
    func recognizePanGesture(sender: UIPanGestureRecognizer) {
        
        
        let translate = sender.translationInView(self.view)
        
        sender.view!.center = CGPoint(x:sender.view!.center.x + translate.x,
            y:sender.view!.center.y + translate.y)
        
        sender.setTranslation(CGPointZero, inView: self.view)
        
        let centerPoint = CGPoint(x:self.view.frame.size.width/2,
            y:self.view.frame.size.height/2)
        
        if sender.state == UIGestureRecognizerState.Ended {
            
            let velocity = sender.velocityInView(self.view)
            
            
            // If velocity less than threshold, final point is center and returns with set velocity
            if abs(velocity.x) < 250 || abs(velocity.y) < 250 {
                let finalPoint = centerPoint
                
                UIView.animateWithDuration(0.2,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {sender.view!.center = finalPoint},
                    completion: nil)
                
            }
                
                
            // If velocity threshold exceeded, animate in the swiped direction
            else {
                
                // Calculate final point based on object center and velocity
                let finalPoint = CGPoint(x:sender.view!.center.x + (velocity.x),
                    y:sender.view!.center.y + (velocity.y))
                
                // Change in y and x
                let dy = Float(centerPoint.y - finalPoint.y)
                let dx = Float(centerPoint.x - finalPoint.x)
                
                // Calculate angle and correct rotation
                angle = CGFloat(atan2(dy,dx)*Float((180/M_PI)))
                
                if angle < -90 {
                    angle = angle + 270
                }
                else {
                    angle = angle - 90
                }
                
                if angle < 0 {
                    angle = angle + 360
                }
                

                
                UIView.animateWithDuration(1,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveLinear,
                    animations: {sender.view!.center = finalPoint },
                    completion: { (finished: Bool) -> Void in
                        sender.view!.removeFromSuperview()

                        self.sendAnother.hidden = false
                        // Fade the refresh image button back in
                        UIView.animateWithDuration(0.5,
                            delay: 0,
                            options: UIViewAnimationOptions.CurveEaseIn,
                            animations: {
                            self.sendAnother.alpha = 1
                            }, completion: { finished in
                                self.sendAnother.hidden = false
                        })
                        
                        self.swipedHeading = (Float(self.currentHeading.trueHeading) + Float(self.angle)) % 360
                        print("currentHeading is: \(self.currentHeading.trueHeading)")
                        print("Swiped Heading iself.s: \(self.swipedHeading)")
                        
                        self.sendToClosestNeighbor(0);
                        print("animation complete and removed from superview")
                })
            }
        }
    }

    
    
    /***********************IMAGE HANDLING*****************************/
    
     
    @IBAction func openCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera;
            
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
    }
    
     
     
    /*
    * Load image with given filename
    */
    func loadImage(image: UIImageView) {
        
        
        
        let maxDimension = 175
        
        let width = image.image!.size.width
        let height = image.image!.size.height
        
        let scaledHeight: Double
        let scaledWidth: Double
        
        if width > height {
            scaledWidth = Double(maxDimension)
            scaledHeight = (Double(height) * scaledWidth)/(Double(width))
        }
            
        else {
            
            scaledHeight = Double(maxDimension)
            scaledWidth = (Double(width) * scaledHeight)/(Double(height))
        }
        
        image.frame = CGRect(x: Double(self.view.frame.size.width/2-CGFloat(scaledWidth/2)), y: Double(self.view.frame.size.height/2-CGFloat(scaledHeight/2)), width: scaledWidth , height: scaledHeight)
        
        
        view.addSubview(image)
        
        image.userInteractionEnabled = true
        image.addGestureRecognizer(panGesture)
        
        
        // Fade out reload button
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.sendAnother.alpha = 0
            }, completion: { finished in
                self.sendAnother.hidden = true
        })
    }
    
    /*
    * Reload the previously swiped image
    */
    @IBAction func reload(sender: AnyObject) {
        
        // stop animation if still animating and remove image
        if image.center.x != self.view.frame.size.width/2 && image.center.y != self.view.frame.size.height/2 {
            if image.isAnimating() {
                image.stopAnimating()
            }
            image.removeFromSuperview()
        }
        
        self.loadImage(image)
        
    }
    
    @IBAction func openPhotos(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker!.allowsEditing = false
            
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker .dismissViewControllerAnimated(true, completion: nil)
        let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Clear the previous image if one already exists
        if image != nil {
            image.removeFromSuperview()
        }
        
        image = UIImageView(image: selectedImage)
        loadImage(image)
    }
    
    /*****************************NEIGHBOR SORTING*****************************/
    
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
        
        var angle = b * (180 / M_PI)
        if (b < 0) {
            angle = angle + 360
        }
        return angle
        
    }

    
//    @IBAction func callSendToClosest(sender: AnyObject) {
//        sendToClosestNeighbor(1)
//    }

    func sendToClosestNeighbor(sort: Int) {
        if (DEBUG) {
            print("Sending to closest neighbor")
        }
        
        let nearbyUsers = findNeighbors()
        var sortedNeighbors = [PFObject]()
        sortedNeighbors = sortNeighbors(PFUser.currentUser()!, neighbors: nearbyUsers, sortBy: sort)
        
        if (sortedNeighbors.count != 0) {
            let closestNeighbor = sortedNeighbors[0]
            
            let toSend = PFObject(className: "sentPicture")
            
            toSend["date"] = NSDate()
            toSend["recipient"] = closestNeighbor
            toSend["sender"] = PFUser.currentUser()
            toSend["hasBeenRead"] = false
            
            let filename = "image.jpg"
            let jpgImage = UIImageJPEGRepresentation(image.image!, 1.0)
            let imageFile = PFFile(name: filename, data: jpgImage!)
            toSend["image"] = imageFile
            
            toSend.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    print("Saved toSend object.")
                }
                else {
                    print("Failed saving toSend object")
                }
            }
            
        }
        else {
            print("No closest neighbor found")
        }
    }
        
    // Sorting function
    // Pass in 1 to sort by distance, otherwise sorts by bearing
    @IBAction func callSortNeighbors(sender: AnyObject) {
        
        let users = findNeighbors()
        
        let sortedNeighbors = sortNeighbors(PFUser.currentUser()!, neighbors: users, sortBy: 0)
        print(sortedNeighbors)
    }

    func sortNeighbors(sender : PFObject, neighbors : Array<PFObject>, sortBy : Int) -> Array<PFObject> {
        var doubleToObjects = [Double : Array<PFObject>]()
        var distances = [Double]()
        
        for n in neighbors {
            var distance = 0.0
            // Sort by distance
            if sortBy == 1 {
                distance = Haversine(sender["latitude"] as! Double, lonA: sender["longitude"] as! Double,
                    latB : n["latitude"] as! Double, lonB : n["longitude"] as! Double)
            }
            // Sort by bearing
            else {
                let direction = Bearing(sender["latitude"] as! Double, lonA: sender["longitude"] as! Double,
                    latB : n["latitude"] as! Double, lonB : n["longitude"] as! Double)
                
                print("Direction from me to neighbor: \(n["username"]) = \(direction)")

                let a = abs(Double(swipedHeading) - direction)
                let b = 360 - a
                distance = min(a, b)
                
                print("Accuracy of swipe: \(n["username"]) = \(distance)")
            }
            
            // Old entry in dictionary
            var previousEntry = doubleToObjects[distance]
            // Check if someone else has same distance
            if previousEntry == nil {
                var newArray = [PFObject]()
                newArray.append(n)

                doubleToObjects[distance] = newArray
                distances.append(distance)

            }
            else {
                previousEntry!.append(n)
                doubleToObjects[distance] = previousEntry
            }
        }
        
        distances.sortInPlace() // Is this less efficient than regular sort?
        var orderedNeighbors = [PFObject]()
        
        // Convert sorted distances into sorted objects.
        for d in distances {
            let arr = doubleToObjects[d]
            for obj in arr! {
                print(obj["username"])
                orderedNeighbors.append(obj)
            }
        }
        nearestLabel.text = String(orderedNeighbors[0]["username"])
        return orderedNeighbors
    }
    
    
    @IBAction func callFindNeighbors(sender: AnyObject) {
        findNeighbors()
    }
    
    func findNeighbors() -> Array<PFObject> {
        
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
        var users = [PFObject]()
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
            users.removeAtIndex(index)
        }
        catch {
            print("Error getting neighbors!")
        }
        
        return users
    }
    
    
    /****************************RETRIEVE IMAGES*********************************/
    
    @IBAction func getSentPictures(sender: AnyObject) {
        let objs = getPicturesObjectsFromParse()
        let pics = extractPicturesFromObjects(objs)
        
        // ONLY SHOWS FIRST IMAGE
        if (pics.count > 0) {
            let imageView = UIImageView(image: pics[0])
            loadImage(imageView)
        }
        else {
            print("No pictures remaining in parse.")
        }
    }
     
    func getPicturesObjectsFromParse() -> Array<PFObject> {
        
        print("Getting parse images")
        let query = PFQuery(className: "sentPicture")
        query.whereKey("recipient", equalTo: PFUser.currentUser()!)
        query.whereKey("hasBeenRead", equalTo: false)
        
        var pictureObjects = [PFObject]()
        do {
            print("ABOUT TO QUERY")
            try pictureObjects = query.findObjects()
            print("FINISH QUERY")
            for object in pictureObjects {
                object["hasBeenRead"] = true
                object.saveInBackground()
            }
        }
        catch {
            print("Error getting received pictures")
        }
        
        return pictureObjects
    }
    
    func extractPicturesFromObjects(objects : Array<PFObject>) -> Array<UIImage> {
        
        var pictures = [UIImage]()
        for object in objects {
            let picture = object["image"] as! PFFile
            do {
                
                let imageData = try picture.getData()
                let image = UIImage(data: imageData)
                pictures.append(image!)

            }
            catch {
                print("Error getting data for pictures")
            }
            
        }
        return pictures
    }
    
     
     
    
    /****************************LOCATION UPDATES********************************/
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = 5
        
        self.sendAnother.hidden = true
        self.sendAnother.alpha = 0
        
        // For touch detection on an image
        self.initializeGestureRecognizer()
        
        let user = PFUser.currentUser()
        if user == nil {
            print("Could not get current User")
        }
        else {
            // userLabel.text = user?.username
            user!["latitude"] = Double()
            user!["longitude"] = Double()
        }
        
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.userObjectId = user!.objectId!
                if (self.DEBUG) {
                    print(self.userObjectId)
                }
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
            latitudeLabel.text = String(user!["latitude"])
            longitudeLabel.text = String(user!["longitude"])
        }
        
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                if (self.DEBUG) {
                    print("Saved Successfully")
                }
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
    
    @IBAction func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
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
