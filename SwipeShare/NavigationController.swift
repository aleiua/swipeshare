//
//  NavigationController.swift
//  SwipeShare
//
//  Created by Troy Palmer on 5/23/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

class NavigationController: UINavigationController {
    
    var locationNavigationController: UINavigationController!
    var locationViewController: LocationViewController!
    
    var containerNavigationController: UINavigationController!
    
    var settingsViewController: SettingsViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("navigation view loaded")
        
        locationViewController = UIStoryboard.locationViewController()
        
        locationNavigationController = UINavigationController(rootViewController: locationViewController)
        view.addSubview(locationNavigationController.view)
        addChildViewController(locationNavigationController)
        
        locationNavigationController.didMoveToParentViewController(self)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
    class func locationViewController() -> LocationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController
        
    }
    
    
}
