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
import CoreData


// Protocol written for container
@objc
protocol LocationViewControllerDelegate {
    optional func toggleSettingsPanel()
}


class LocationViewController: ViewController, LKLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CBPeripheralManagerDelegate {

    // MARK: Properties

    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let locationUtils = Utilities()
    
    @IBOutlet weak var inboxButton: UIBarButtonItem!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var nearestLabel: UILabel!
    @IBOutlet weak var sendAnother: UIButton!
    @IBOutlet weak var intendedUserField: UITextField!
    
    var locationManager: LKLocationManager!
    
    var setupComplete = false
    var initialViewDidLoad = true

    var beaconRegion: CLBeaconRegion!
    var peripheralManager: CBPeripheralManager!
    var beaconPeripheralData: NSDictionary!
    
    var currentLocation: CLLocation!
    var currentHeading = Float()
    var headingBias = Float()
    
    var userObjectId = String()
    var userLatitude = Double()
    var userLongitude = Double()
    var blockedUsers = [User]()
    var friendUsers = [User]()

    
    var angle: CGFloat!
    var panGesture: UIPanGestureRecognizer!
    var image: UIImageView!
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    
    var swipedHeading = Float()
    var DEBUG = false
    var ACCURACY = false
    
    // Errors in swiping or distance to other user.
    var STORE_DATA = true
    var userToSpacialError = [PFObject : Double]()
    var intendedRecipient: PFObject?
    
    
    // Core Data Stuff
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var currentUserProfile: CurrentUserProfile?
    
    
    
    @IBAction func settingsMenuButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Settings page")
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
            self.presentViewController(viewController, animated: true, completion: nil)
            
        })
    }
    

   /*****************************GESTURE HANDLING********************************/
    
    /*
    * Initialize panGestureRecognizer
    */
    func initializeGestureRecognizer() {
        //For PanGesture Recognition
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
                        
                        self.swipedHeading = (self.currentHeading + Float(self.angle)) % 360
                        print("currentHeading is: \(self.currentHeading)")
                        print("Swiped Heading iself.s: \(self.swipedHeading)")
                        self.passNeighborsToChecklist(0);
                        print("animation complete and removed from superview")
                })
            }
        }
    }

    
    
    /***********************IMAGE HANDLING*****************************/
    

    
    @IBOutlet weak var removeButton: UIButton!
    

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
        
        if (image.image != nil && image.hidden == true) {
            image.hidden = false
        }
        
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
        
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        
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
    * Resend the previously swiped image
    */
    @IBAction func reload(sender: AnyObject) {
        
        // stop animation if still animating and remove image
        if (image.center.x != self.view.frame.size.width/2) && (image.center.y != self.view.frame.size.height/2) || (image.hidden == true) {
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
    
    
    
    func animateBottomButtonsBack() {

        // Move Camera Button
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.removeButton.alpha = 0

                self.view.layoutIfNeeded()
            },
            completion: { (finished: Bool) -> Void in
        })
    }




    /********************DISTANCE AND BEARING CALCULATIONS********************/
    // Relocated to LocationUtilities
    
    /*
     Rough Distances:
     .1 = 11km
     .01 = 1km = 1000m
     .001 = .1km = 100m
     .0001 = .01km = 10m
     */
    
    var searchDistance = 0.001
    var earthRadius = 6371.0
    var ftInMiles = 5280.0
    
    var milesToKM = 0.621371
    var distanceToLat = 110.574
    var distanceToLong = 111.320
    
    func saveNewRadius(distance: Float) {
        
        let miles = Double(distance) / ftInMiles
        let km = miles / milesToKM
        
        appDel.latSearchDistance = km / distanceToLat
        appDel.longSearchDistance = km / (distanceToLong * cos(userLatitude))
        
    }
    
    /*****************************NEIGHBOR SORTING*****************************/

    
    func findNeighbors() -> Array<PFObject> {

        let currentObjectID = PFUser.currentUser()!.objectId
        
        print("Querying for neighbors")
        let query = PFQuery(className:"_User")
        query.whereKey("latitude",
            greaterThan: (userLatitude - appDel.latSearchDistance))
        query.whereKey("latitude",
            lessThan: (userLatitude + appDel.latSearchDistance))
        query.whereKey("longitude",
            greaterThan: (userLongitude - appDel.longSearchDistance))
        query.whereKey("longitude",
            lessThan: (userLongitude + appDel.longSearchDistance))
        query.whereKey("objectId", notEqualTo: currentObjectID!)
        
        
        // Get all close neighbors
        var users = [PFObject]()
        var isBlocked: Bool
        var isFriend: Bool

        do {
            try users = query.findObjects()

            for (i, user) in users.enumerate().reverse() {
                // Filter out blocked users by removing from list returned by query
                isBlocked = false
                for blockedUser in blockedUsers {
                    if (String(user["username"]) == blockedUser.username) {
                        users.removeAtIndex(i)
                        isBlocked = true
                        break
                    }
                }
                
                // Filter out non-Friend users if sharing with friends only
                isFriend = false
                if (currentUserProfile!.shareWithFriendsSetting && !isBlocked) {
                    for friend in friendUsers {
                        if (String(user["username"]) == friend.username) {
                            isFriend = true
                        }
                    }
                    if !(isFriend) {
                        print("attempting to remove non-friend from \(users) at index \(i)")
                        users.removeAtIndex(i)
                    }
                }
                
                print("Adjacent User: " + String(user["name"]))
            }
        }
        catch {
            print("Error getting neighbors!")
        }
        
        return users
    }

    // Sorting function
    // Pass in 1 to sort by distance, otherwise sorts by bearing
    func sortNeighbors(sender : PFObject, neighbors : Array<PFObject>, sortBy : Int) -> Array<PFObject> {
        
        userToSpacialError.removeAll()
        var spacialErrors = [Double : Array<PFObject>]()
        var distances = [Double]()
        
        for n in neighbors {
            var distance = 0.0
            // Sort by distance
            if sortBy == 1 {
                distance = locationUtils.Haversine(sender["latitude"] as! Double, lonA: sender["longitude"] as! Double,
                    latB : n["latitude"] as! Double, lonB : n["longitude"] as! Double)
            }
            // Sort by bearing
            else {
                let direction = locationUtils.Bearing(sender["latitude"] as! Double, lonA: sender["longitude"] as! Double,
                    latB : n["latitude"] as! Double, lonB : n["longitude"] as! Double)
              
                let a = abs(Double(swipedHeading) - direction)
                let b = 360 - a
                distance = min(a, b)
                
                if (ACCURACY) {
                    print("Direction from me to neighbor: \(n["name"]) = \(direction)")
                    print("Accuracy of swipe: \(n["name"]) = \(distance)")
                }
            }
            
            // Data retrieval
            userToSpacialError[n] = distance
            
            
            // Old entry in dictionary
            var previousEntry = spacialErrors[distance]
            // Check if someone else has same distance
            if previousEntry == nil {
                var newArray = [PFObject]()
                newArray.append(n)

                spacialErrors[distance] = newArray
                distances.append(distance)

            }
            else {
                previousEntry!.append(n)
                spacialErrors[distance] = previousEntry
            }
        }
        
        distances.sortInPlace() // Is this less efficient than regular sort?
        var orderedNeighbors = [PFObject]()
        
        
        // Convert sorted distances into sorted objects.
        for d in distances {
            let arr = spacialErrors[d]
            for obj in arr! {
                orderedNeighbors.append(obj)
            }
        }
        
        if (DEBUG) {
            print("Sorted Neighbors: \(orderedNeighbors)")
        }

        
        return orderedNeighbors
    }
    
    
    func getNeighbors(sort : Int) -> Array<PFObject> {
        return sortNeighbors(PFUser.currentUser()!, neighbors: findNeighbors(), sortBy: sort)
    }
    
    
    func passNeighborsToChecklist(sort: Int) {
        
        var neighbors = getNeighbors(0)
        
        if (neighbors.count != 0) {
            if (STORE_DATA) {
                intendedRecipient = neighbors[0]
            }
            // if it finds users, display the checklist
            let checkListViewController = storyboard!.instantiateViewControllerWithIdentifier("checklist") as! CheckListViewController
            checkListViewController.modalPresentationStyle = .OverFullScreen
            checkListViewController.delegate = self
            checkListViewController.items = neighbors
            presentViewController(checkListViewController, animated: true, completion: nil)
        }
        else {
            // otherwise, show the error overlay
            let overlayView = OverlayView()
            overlayView.displayView(view)
        }
    }
    

    
    func sendToUsers(users: [PFObject], bluetooth: Bool) {
        if (DEBUG) {
            print("Sending to users")
        }
        
        let filename = "image.jpg"
        let jpgImage = UIImageJPEGRepresentation(image.image!, 0.5)
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
        
        if (!bluetooth && STORE_DATA && users.count == 1) {
            storeActionData(users[0])
        }
        
    }

    
    func storeActionData(actualRecipient : PFObject) {
        
        print("Storing information")
        
        let data = PFObject(className: "actionData")
        
        let currUser = PFUser.currentUser()
        
        data["currentUser"] = currUser!["name"]
        data["currentHeading"] = Double(currentHeading)
        data["swipedHeading"] = Double(swipedHeading)
        data["currentLatitude"] = currUser!["latitude"]
        data["currentLongitude"] = currUser!["longitude"]
        
        data["intendedRecipient"] = intendedRecipient!["name"]
        data["intendedBearingAccuracy"] = userToSpacialError[intendedRecipient!]
        data["intendedLatitude"] = intendedRecipient!["latitude"]
        data["intendedLongitude"] = intendedRecipient!["longitude"]
        
        data["actualRecipient"] = actualRecipient["name"]
        data["actualBearingAccuracy"] = userToSpacialError[actualRecipient]
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

    
    /****************************RETRIEVE IMAGES*********************************/
     // Check to see if the user is blocked
    func isBlocked(username: String) -> Bool {
        for user in blockedUsers {
            print(user.username)
            if user.username == username {
                return true
            }
        }
        return false
    }

     
    func getPictureObjectsFromParse() -> Array<PFObject> {
        
        print("Getting parse images")
        let query = PFQuery(className: "sentPicture")
        query.whereKey("recipient", equalTo: PFUser.currentUser()!)
        query.whereKey("hasBeenRead", equalTo: false)
        query.includeKey("sender")
        query.orderByDescending("date")
        
        var pictureObjects = [PFObject]()
        do {
            try pictureObjects = query.findObjects()
            
            print("Entering for loop")
            print(pictureObjects.count)
            
            for object in pictureObjects {
                
                let messageSender = object["sender"] as! PFUser
                let sender: User

                // Check if sender exists in local User storage
                let checkForSenderFetchRequest = NSFetchRequest(entityName: "User")
                let predicate = NSPredicate(format: "%K == %@", "username", messageSender["username"] as! String)
                checkForSenderFetchRequest.predicate = predicate
                
                // Execute Fetch Request to check if User exists locally
                do {
                    let users = try self.managedObjectContext.executeFetchRequest(checkForSenderFetchRequest)
                    
                    // If the user does exist locally - set Store User to the local user entity for updating purposes
                    if users.count != 0 {
                        sender = users[0] as! User
                        print("sender already stored")
                        
                    } else {        // Create a new User entity to store
                        print("creating new sender")
                        let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext)
                        sender = User(username: messageSender["username"] as! String, displayName: messageSender["name"] as! String, entity: userEntity!, insertIntoManagedObjectContext: self.managedObjectContext)
                        
                        if let picture = messageSender["profilePicture"] as? PFFile {
                            
                            picture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                                if (error == nil) {
                                    
                                    sender.profImageData = imageData
                                    
                                }
                            }
                        }
                        else {
                            print("Error getting image data")
                        }
                        
                    }

                    // If sender is a blocked user - do not save or display incoming message
                    if sender.status == "blocked" {
                        abort()
                    }
                    
                    // Filter messages coming from blocked users
                    //if (!isBlocked(msgSender["username"] as! String)) {
                    
                    
                    // Create message object
                    let messageId = object.objectId
                    let sentDate = object.createdAt! as NSDate
                    let entityDescripition = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext)
                    let message = Message(date: sentDate, imageData: nil, objectId: messageId!, entity: entityDescripition!, insertIntoManagedObjectContext: managedObjectContext)
                    
                    
                    // Set up relationship between message and sender in core data
                    message.user = sender
                    
                    sender.mutableSetValueForKey("messages").addObject(message)
                    
                    // update sender most recent communication date
                    sender.mostRecentCommunication = sentDate
                    
                    
                    // Set message object to read on parse - which means it has been downloaded to phone
                    object["hasBeenRead"] = true
                    object.saveInBackground()
                    
                } catch {   // Catch any errors fetching from Core Data
                    let fetchError = error as NSError
                    print(fetchError)
                }
                
                

                    
                // SAVING MANAGED OBJECT CONTEXT - SAVES MESSAGES TO CORE DATA
                do {
                    try managedObjectContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
        // Handle errors in getting pictures from parse
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
    
    func initializeDisplay() {
        
        print("Initializing Display")
        
        self.promptLabel?.hidden = false
        self.sendAnother?.hidden = true
        self.sendAnother?.alpha = 0
        

        self.image?.image = nil
        self.image?.hidden = true
        
    }
    
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        initializeLocationManager()

        
        self.sendAnother.hidden = true
        self.sendAnother.alpha = 0
        
        // For touch detection on an image
        self.initializeGestureRecognizer()
        
        
        let user = PFUser.currentUser()
        if user == nil {
            if (DEBUG) {
                print("ViewDidLoad: Could not get current User")
            }
            
//            let viewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Initial") as! ViewController
//            viewController.delegate = self
//            self.presentViewController(viewController, animated: true, completion: nil)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("presenting login view")

                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Initial") as! ViewController
                viewController.delegate = self
                self.presentViewController(viewController, animated: true, completion: nil)
                
            })
            return
        }
        else {
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
            else {
                if (self.DEBUG) {
                    print("Error saving user in viewDidLoad")
                }
            }
        }
        
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackground()
        

        loadUserProfile(user!)
        getBlockedUsers()
        getFriendList()
        setUpiBeacon(user!)
        
        setupComplete = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    /*************************** Location Manager Functionalities *******************************/
    
    
    func initializeLocationManager() {
        locationManager = LKLocationManager()
        locationManager.apiToken = "76f847c677f70038"
        locationManager.requestAlwaysAuthorization()
        locationManager.advancedDelegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
        
        if !(setupComplete) && PFUser.currentUser() != nil {
            setupProtocols(PFUser.currentUser()!)
        }

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
                
                self.userLatitude = self.currentLocation.coordinate.latitude
                self.userLongitude = self.currentLocation.coordinate.longitude
                
                user!.saveInBackgroundWithBlock { (success, error) -> Void in
                    if success {
                        if (self.DEBUG) {
                            print("Location saved successfully")
                        }
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
        let senderName = sender["name"]
        let recipientName = recipient["name"]
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
    
    /*************************** Settings Segue *******************************/
     
    @IBAction func segueHome(segue: UIStoryboardSegue) {
        // segue back
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        
        if let id = identifier {
            print(id)
            if id == "segueHome" {
                let unwindSegue = UIStoryboardUnwindSegueFromLeft(identifier: id, source: fromViewController, destination: toViewController)
                return unwindSegue
            }
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    
    
    
    
    /****************************iBeacon Region Establishment********************************/
    
    
    /*
    * Set up the iBeacon region for the current user by creating the appropriate identifier and beginning to broadcast
    */
    func setUpiBeacon(user: PFUser) {
        
        // Set up iBeacon region
        let uuid = NSUUID(UUIDString: "10e00516-fa71-11e5-86aa-5e5517507c66")! // arbitrary constant UUID
        let beaconID = "yaw_iBeacon_region"
        
        //convert user ID to major and minor values to broadcast
        var major: CLBeaconMajorValue!
        var minor: CLBeaconMinorValue!
        let identifier = user["btIdentifier"] as? NSNumber
        if (Int(identifier!) > 65535) {
            major = 65535
            minor = CLBeaconMinorValue(Int(identifier!) - 65535)
        }
        else {
            major = CLBeaconMajorValue(Int(identifier!))
            minor = 0
        }
        
        let beaconRegionBroadcast = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: beaconID)
        
        let beaconRegionFind = CLBeaconRegion(proximityUUID: uuid, identifier: beaconID)
        
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringForRegion(beaconRegionBroadcast)
        locationManager.startRangingBeaconsInRegion(beaconRegionFind)
        beaconPeripheralData = beaconRegionBroadcast.peripheralDataWithMeasuredPower(nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    
     /*
     *  Print out detected beacons
     */
    func locationManager(manager: LKLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
//        print(beacons)
        
        if (image != nil && image.hidden == false) {
            for beacon in beacons {
                if (beacon.rssi > -38 && beacon.rssi != 0 && image.hidden == false) {
                    
                    let neighbor = findBluetoothNeighbor((Int(beacon.major) + Int(beacon.minor)))
                    
                    if !(neighbor.isEmpty) {
                        let bumpViewController = storyboard!.instantiateViewControllerWithIdentifier("bumpvalidation") as! BumpValidationViewController
                        bumpViewController.modalPresentationStyle = .OverFullScreen
                        bumpViewController.delegate = self
                        bumpViewController.recipient = neighbor
                        presentViewController(bumpViewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func refreshSymbol() {
        
        image.hidden = true
        
        // Fade the refresh image button back in
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.sendAnother.alpha = 1
            }, completion: { finished in
                self.sendAnother.hidden = false
        })

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
    


    
    /*
    * Determine the user corresponding to the given identifier by checking in Parse
    */
    func findBluetoothNeighbor(identifier : Int) -> Array<PFObject> {

//        print("identifier: \(identifier)")
        let query = PFQuery(className:"_User")
        query.whereKey("btIdentifier", equalTo: identifier)
        
        
        // Get all close neighbors
        var neighbor = [PFObject]()
        do {
            try neighbor = query.findObjects()
            
        }
        catch {
            print("Error getting neighbors!")
        }

        // If bluetooth sharing with friends only, filter out non-friend users
        if (currentUserProfile!.shareWithFriendsSetting) {
            var friendNeighbor = [PFObject]()
            for user in neighbor {
                for friend in friendUsers {
                    
                    // If the user is found within friends, then add them to the confirmed users list
                    if (String(user["username"]) == friend.username) {
                        friendNeighbor.append(user)
                    }
                }
            }
            return friendNeighbor
        }
        else{
            return neighbor
        }

    }
    
    
    /*************************** Friend Operations *******************************/
     
    func getBlockedUsers() {
        
        // Fetch list of blocked users by username from CoreData
        let blockedFetchRequest = NSFetchRequest(entityName: "User")
        // Create Predicate
        let blockedPredicate = NSPredicate(format: "%K == %@", "status", "blocked")
        blockedFetchRequest.predicate = blockedPredicate
        do {
            blockedUsers = try managedObjectContext.executeFetchRequest(blockedFetchRequest) as! [User]
            print(blockedUsers.count)
        } catch {
            print("error fetching list of blocked users")
        }
    }
    
    
    func getFriendList() {
        
        // Fetch list of blocked users by username from CoreData
        let friendFetchRequest = NSFetchRequest(entityName: "User")
        // Create Predicate
        let friendPredicate = NSPredicate(format: "%K == %@", "status", "friend")
        friendFetchRequest.predicate = friendPredicate
        do {
            friendUsers = try managedObjectContext.executeFetchRequest(friendFetchRequest) as! [User]
            print(friendUsers.count)
        } catch {
            print("error fetching list of blocked users")
        }
        
    }
    
    func loadUserProfile(user: PFUser) {
        // Update the current user entity
        let userProfileFetchRequest = NSFetchRequest(entityName: "CurrentUserProfile")
        let userProfilePredicate = NSPredicate(format: "%K == %@", "displayName", user["name"] as! String)
        var possibleUserProfile: [CurrentUserProfile] = [CurrentUserProfile]()
        userProfileFetchRequest.predicate = userProfilePredicate
        do {
            possibleUserProfile = try managedObjectContext.executeFetchRequest(userProfileFetchRequest) as! [CurrentUserProfile]
        } catch {
            print("error fetching current user profile")
        }
        
        if (possibleUserProfile.isEmpty) {
            
            print("making a new user settings profile")
            
            let userProfileEntity = NSEntityDescription.entityForName("CurrentUserProfile", inManagedObjectContext: self.managedObjectContext)
            currentUserProfile = CurrentUserProfile(username: PFUser.currentUser()!.username!, displayName: user["name"] as! String, entity: userProfileEntity!, insertIntoManagedObjectContext: self.managedObjectContext)
        }
        else {
            
            // Use the existing one
            print("opening an existing user profile")
            currentUserProfile = possibleUserProfile[0]
        }
    }
    
    
    
    
    func setupProtocols(user: PFUser) {
        
        user["latitude"] = Double()
        user["longitude"] = Double()
        
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.userObjectId = user.objectId!
                if (self.DEBUG) {
                    print(self.userObjectId)
                }
            }
            else {
                if (self.DEBUG) {
                    print("Error saving user in viewDidLoad")
                }
            }
        }
        
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackground()
        
        loadUserProfile(user)
        getBlockedUsers()
        getFriendList()
        setUpiBeacon(user)
        setupComplete = true
    }

    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "msgListSegue" {
            getPictureObjectsFromParse()
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "conversationsSegue" {
            getPictureObjectsFromParse()
        }
        
        if segue.identifier == "settingsSegue" {
            let destination = segue.destinationViewController as! SettingsViewController
            destination.delegate = self
        }

        
    }


}
