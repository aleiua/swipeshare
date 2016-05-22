//
//  ContainerViewController.swift
//  SwipeShare
//
//  Created by Troy Palmer on 3/4/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


enum SlideMenuState {
    case SettingsPanelCollapsed
    case SettingsPanelExpanded
}

class ContainerViewController: UIViewController, UINavigationControllerDelegate {
    
    var locationNavigationController: UINavigationController!
    var locationViewController: LocationViewController!
    
    var containerNavigationController: UINavigationController!
    
    var settingsViewController: SettingsViewController?
    
    var currentState: SlideMenuState = .SettingsPanelCollapsed {
        didSet {
            let shouldShowShadow = currentState != .SettingsPanelCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("container view loaded")
        
        locationViewController = UIStoryboard.locationViewController()
        locationViewController.containerDelegate = self

        locationNavigationController = UINavigationController(rootViewController: locationViewController)
        view.addSubview(locationNavigationController.view)
        addChildViewController(locationNavigationController)
        
        locationNavigationController.didMoveToParentViewController(self)
        
//        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
//        locationNavigationController.view.addGestureRecognizer(swipeGestureRecognizer)
                
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
}

extension ContainerViewController: LocationViewControllerDelegate {
    
    func toggleSettingsPanel() {
        
        
        let notAlreadyExpanded = (currentState != .SettingsPanelExpanded)
        
        if notAlreadyExpanded {
            addSettingsViewController()
        }
        
        animateSettingsPanel(shouldExpand: notAlreadyExpanded)
        
    }
    
    func addSettingsViewController() {
        if (settingsViewController == nil) {
            settingsViewController = UIStoryboard.settingsViewController()
  
            addChildSidePanelController(settingsViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SettingsViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        print("attempting to toggle settings panel")
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateSettingsPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .SettingsPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(locationNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .SettingsPanelCollapsed
                
                self.settingsViewController!.view.removeFromSuperview()
                self.settingsViewController = nil;
            }
        }
    }
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.locationNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            locationNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            locationNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

//
//extension ContainerViewController: UIGestureRecognizerDelegate {
//    // MARK: Gesture recognizer
//    
//    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
//        
//        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
//        
//        switch(recognizer.state) {
//        case .Began:
//            if (currentState == .SettingsPanelCollapsed) {
//                if (gestureIsDraggingFromLeftToRight) {
//                    addSettingsViewController()
//                }
//                
//                showShadowForCenterViewController(true)
//            }
//            
//        case .Changed:
//            
//            if (currentState == .SettingsPanelCollapsed) {
//                if recognizer.translationInView(view).x > 0 {
//                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
//                    recognizer.setTranslation(CGPointZero, inView: view)
//                }
//            }
//            else {
//                if recognizer.translationInView(view).x < 0 {
//                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
//                    recognizer.setTranslation(CGPointZero, inView: view)
//                }
//                
//            }
//
//            
//        case .Ended:
//            
//            if (settingsViewController != nil) {
//                // animate the side panel open or closed based on whether the view has moved more or less than halfway
//                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
//                animateSettingsPanel(shouldExpand: hasMovedGreaterThanHalfway)
//            }
//            
//        default:
//            break
//        }
//    }
//    
//}

private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
    class func locationViewController() -> LocationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController

    }
    

}