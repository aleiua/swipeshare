//
//  OverlayView.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 4/10/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import UIKit

class OverlayView: UIView {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
    Loads a view instance from the xib file
    
    - returns: loaded view
    */
    func loadViewFromXibFile() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "OverlayView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        translatesAutoresizingMaskIntoConstraints = false
        
//        titleLabel.text = NSLocalizedString("Sent", comment: "")
        
        /// Adds a shadow to our view
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
//        view.layer.shadowColor = UIColor.blackColor().CGColor
//        view.layer.shadowOpacity = 0.2
//        view.layer.shadowRadius = 4.0
//        view.layer.shadowOffset = CGSizeMake(0.0, 8.0)
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = 20.0
    }
    
    /**
     Updates constraints for the view. Specifies the height and width for the view
     */
    override func updateConstraints() {
        super.updateConstraints()
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 170.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 170.0))
        
        addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
    }
    
    private func hideView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.1, 0.1)
            }) { (finished) -> Void in
                self.removeFromSuperview()
        }
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: onView, attribute: .CenterY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: onView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
        // display the view
        transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                // wait 1.5 seconds, then hide it
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.hideView()
                }
        }
    }
    
}