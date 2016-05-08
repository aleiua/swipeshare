//
//  LeftRightSegue.swift
//  SwipeShare
//
//  Created by Garrett Watumull on 5/8/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit
import QuartzCore


class UISegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.40,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { finished in
                src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
}


class UIStoryboardUnwindSegueFromLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransformMakeTranslation(0, 0)
        
        UIView.animateWithDuration(0.40,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                src.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
            },
            completion: { finished in
                src.dismissViewControllerAnimated(false, completion: nil)
            }
        )
    }
}
