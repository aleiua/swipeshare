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
import LocationKit
import CoreBluetooth


// Protocol written for container
@objc
protocol LocationViewControllerDelegate {
    optional func toggleSettingsPanel()
}


class LocationViewController: ViewController, LKLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CBPeripheralManagerDelegate {

    // MARK: Properties
    
    // Button for accessing photos
    @IBOutlet weak var photoz: UIButton!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var nearestLabel: UILabel!
    @IBOutlet weak var sendAnother: UIButton!
    @IBOutlet weak var intendedUserField: UITextField!
    
    var locationManager: LKLocationManager!

    var beaconRegion: CLBeaconRegion!
    var peripheralManager: CBPeripheralManager!
    var beaconPeripheralData: NSDictionary!
    
    
    var currentLocation: CLLocation!
    var currentHeading = Float()
    var headingBias = Float()
    
    var userObjectId = String()
    var userLatitude = Double()
    var userLongitude = Double()
    
    var angle: CGFloat!
    var panGesture: UIPanGestureRecognizer!
    var image: UIImageView!
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    
    var swipedHeading = Float()
    var DEBUG = false
    var ACCURACY = false
   
    
    // New things for container
    var delegate: LocationViewControllerDelegate?
    
    @IBAction func settingsMenuButton(sender: AnyObject) {
        print("settings menu button pressed")
        delegate?.toggleSettingsPanel?()
    }
    
    
    let msgManager = MessageManager.sharedMessageManager
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
            if abs(velocity.x) < 200 || abs(velocity.y) < 200 {
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
                        // make "send another copy" pressable again
                        self.sendAnother.hidden = false
                        // Fade the refresh image button back in
                        UIView.animateWithDuration(0.2,
                            delay: 0,
                            options: UIViewAnimationOptions.CurveEaseIn,
                            animations: {
                                self.sendAnother.alpha = 1
                            }, completion: { finished in
                                self.sendAnother.hidden = false
                        })
                        
                        self.swipedHeading = self.currentHeading + Float(self.angle) % 360
                        print("currentHeading is: \(self.currentHeading)")
                        print("Swiped Heading iself.s: \(self.swipedHeading)")
                        self.findClosestNeighbor(0);
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
        
        promptLabel.hidden = true
        let screenWidth = UIScreen.mainScreen().bounds.width
        let maxDimension = round(screenWidth*0.6)
        
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
    * Add shadow beneath a UIImageView
    */
    func applyPlainShadow(view: UIImageView) {
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    
    /*
    * Resend the previously swiped image
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

    

    func sendToClosestNeighbor(sort: Int) {
        if (DEBUG) {
            print("Sending to closest neighbor")
        }
        
        let nearbyUsers = findNeighbors()
        if (nearbyUsers.count > 0) {
            var sortedNeighbors = [PFObject]()
            sortedNeighbors = sortNeighbors(PFUser.currentUser()!, neighbors: nearbyUsers, sortBy: sort)
            
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
            pushToUser(PFUser.currentUser()!, recipient: closestNeighbor as! PFUser, photo: toSend)
        }
    }
    
    func findClosestNeighbor(sort: Int) {
        let nearbyUsers = findNeighbors()
        var sortedNeighbors = [PFObject]()
        sortedNeighbors = sortNeighbors(PFUser.currentUser()!, neighbors: nearbyUsers, sortBy: sort)
        if (sortedNeighbors.count != 0) {
            // if it finds users, display the checklist
            let checkListViewController = storyboard!.instantiateViewControllerWithIdentifier("checklist") as! CheckListViewController
            checkListViewController.modalPresentationStyle = .OverCurrentContext
            checkListViewController.delegate = self
            checkListViewController.items = sortedNeighbors
            presentViewController(checkListViewController, animated: true, completion: nil)
        }
        else {
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.displayView(view)
        }
    }
    
    func sendToUsers(users: [PFObject]) {
        if (DEBUG) {
            print("Sending to users")
        }
        
        let filename = "image.jpg"
        let jpgImage = UIImageJPEGRepresentation(image.image!, 1.0)
        let imageFile = PFFile(name: filename, data: jpgImage!)
        
        for user in users {
            let toSend = PFObject(className: "sentPicture")
            toSend["date"] = NSDate()
            toSend["sender"] = PFUser.currentUser()
            toSend["hasBeenRead"] = false
            toSend["image"] = imageFile
            toSend["recipient"] = user
            toSend.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    print("Saved toSend object.")
                }
                else {
                    print("Failed saving toSend object")
                }
            }
            pushToUser(PFUser.currentUser()!, recipient: user as! PFUser, photo: toSend)
        }
    }

    
    func storeSendingInformation(intendedRecipient : PFObject, actualRecipient : PFObject, intendedBear : Double, actualBear : Double) {
        
        let data = PFObject(className: "sendingData")
        
        let currUser = PFUser.currentUser()
        
        data["currentUser"] = currUser!["username"]
        data["currentHeading"] = Double(currentHeading)
        data["swipedHeading"] = Double(swipedHeading)
        data["currentLatitude"] = currUser!["latitude"]
        data["currentLongitude"] = currUser!["longitude"]
        
        data["intendedRecipient"] = intendedRecipient["username"]
        data["intendedBearingAccuracy"] = intendedBear
        data["intendedLatitude"] = intendedRecipient["latitude"]
        data["intendedLongitude"] = intendedRecipient["longitude"]
        
        data["actualRecipient"] = actualRecipient["username"]
        data["actualBearingAccuracy"] = actualBear
        data["actualLatitude"] = actualRecipient["latitude"]
        data["actualLongitude"] = actualRecipient["longitude"]
        
        data.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Saved data object.")
            }
            else {
                print("Failed saving data")
            }
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
              
                let a = abs(Double(swipedHeading) - direction)
                let b = 360 - a
                distance = min(a, b)
                
                if (ACCURACY) {
                    print("Direction from me to neighbor: \(n["username"]) = \(direction)")
                    print("Accuracy of swipe: \(n["username"]) = \(distance)")
                }
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
        
        // Data Collection Variables
        let intendedUser = "" //self.intendedUserField.text
        
        var intended: PFObject!
        var intendedBearing = Double()
        
        
        // Convert sorted distances into sorted objects.
        for d in distances {
            let arr = doubleToObjects[d]
            for obj in arr! {
                orderedNeighbors.append(obj)
                if (String(obj["username"]) == intendedUser) {
                    intended = obj
                    intendedBearing = d
                }
            }
        }
        
        if (DEBUG) {
            print("Sorted Neighbors: \(orderedNeighbors)")
        }

        // Check to make sure user entered a person.
        if (!(intendedUser ?? "").isEmpty) {
            print("Storing sending information")
            storeSendingInformation(intended, actualRecipient : orderedNeighbors[0], intendedBear : intendedBearing, actualBear : distances[0])
        }

//        nearestLabel.text = String(orderedNeighbors[0]["username"])
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
                    if (DEBUG) {
                        print("Found myself when looking for nearby neighbors")
                    }
                    index = i
                }
            }
            if (index != -1) {
                if (DEBUG) {
                    print("Removing myself from neighby neighbors")
                }
                users.removeAtIndex(index)
            }
        }
        catch {
            print("Error getting neighbors!")
        }
        
        return users
    }
    
    
    /****************************RETRIEVE IMAGES*********************************/
    
    
    func createNewMessageObject(sender: AnyObject) {
//        let msg = Message(sender: <#T##String#>, receiver: PFUser.currentUser()!, text: String?, image: <#T##UIImage?#>)
    }
    
    
    func saveMessage(sender: AnyObject) {
        
    }
    
    @IBAction func getSentPictures(sender: AnyObject) {
        getPictureObjectsFromParse()
        
    }
     
    func getPictureObjectsFromParse() -> Array<PFObject> {
        
        print("Getting parse images")
        let query = PFQuery(className: "sentPicture")
        query.whereKey("recipient", equalTo: PFUser.currentUser()!)
        query.includeKey("sender")
        query.orderByAscending("date")
        
        var pictureObjects = [PFObject]()
        do {
            try pictureObjects = query.findObjects()
            
            print("Entering for loop")
            print(pictureObjects.endIndex)
            for object in pictureObjects {
                let msgSender = object["sender"]
                let msgId = object.objectId
                let sentDate = object.createdAt! as NSDate
                
                let msg = Message(sender: msgSender! as! PFUser, image: nil, date: sentDate, id: msgId!)
                self.msgManager.addMessage(msg)
                
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
        locationManager = LKLocationManager()
        locationManager.apiToken = "76f847c677f70038"
        locationManager.requestAlwaysAuthorization()
        
        //set up iBeacon region
        let uuid = NSUUID(UUIDString: "10e00516-fa71-11e5-86aa-5e5517507c66")! // arbitrary constant UUID
        let beaconID = "yaw_iBeacon_region"
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: beaconID)
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        beaconPeripheralData = beaconRegion.peripheralDataWithMeasuredPower(nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        print("successfully initialized beacon region")
        
        
        locationManager.advancedDelegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        self.sendAnother.hidden = true
        self.sendAnother.alpha = 0
        
        // For touch detection on an image
        self.initializeGestureRecognizer()
        
        let user = PFUser.currentUser()
        if user == nil {
            if (DEBUG) {
                print("ViewDidLoad: Could not get current User")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("presenting login view")

                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: nil)
                
            })
            return
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
        
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackground()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        print("What up?")
    }
    

    // Test comment
    func locationManager(manager: LKLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }
    

    /*
    * Update longitude/latitude locations
    */
    func locationManager(manager:LKLocationManager, var didUpdateLocations locations: Array <CLLocation>) {
        

        if (LKLocationManager.locationServicesEnabled()) {
            
            currentLocation = locationManager.location!
            let loc = locations.removeLast()

            let user = PFUser.currentUser()
            
            
            if user == nil {
                if (DEBUG) {
                    print("LocationUpdate: Could not get current User")
                }
                return
            }
                
            else {
                user!["latitude"] = loc.coordinate.latitude
                user!["longitude"] = loc.coordinate.longitude
                
                user!.saveInBackgroundWithBlock { (success, error) -> Void in
                    if success {
                        if (self.DEBUG) {
                            print("Location saved successfully")
                        }
                        self.userLatitude = self.currentLocation.coordinate.latitude
                        self.userLongitude = self.currentLocation.coordinate.longitude
                    }
                }
            }
        }

    }
    
    /*
    * Update displayed heading
    */
    func locationManager(manager: LKLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        headingBias = 0
        currentHeading = Float(locationManager.heading!.trueHeading) + headingBias
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func logout() {
        print(PFUser.currentUser())
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    
    
    /*************************** Push Notifications *******************************/
    
    func pushToUser(sender: PFUser, recipient: PFUser, photo: PFObject){
        let push = PFPush()
        let senderName = sender["username"]
        let recipientName = recipient["username"]
        let data = [
            "alert" : "\(senderName) sent you a photo!",
            "badge" : "Increment",
            "p" : "\(photo.objectId)"
        ]

        let query = PFInstallation.query()
        query!.whereKey("user", equalTo: recipient)
        
        push.setData(data)
        push.setQuery(query)
        
        
        push.sendPushInBackgroundWithBlock {
            (success: Bool , error: NSError?) -> Void in
            if (success) {
                print("Pushed to \(recipientName).")
            } else if (error!.code == 112) {
                print("Could not send push. Push is misconfigured: \(error!.description).")
            } else {
                print("Error sending push: \(error!.description).")
            }
        }
        
    }
    
    /****************************iBeacon Region Establishment********************************/
    
     /*
     *  Print out detected beacons
     */
    func locationManager(manager: LKLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
    }
    
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
            print("began advertising as iBeacon")
        }
        else if peripheral.state == .PoweredOff {
                peripheralManager.stopAdvertising()
        }
    }

    

    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "msgListSegue" && msgManager.messages.endIndex == 0 {
            getPictureObjectsFromParse()
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
