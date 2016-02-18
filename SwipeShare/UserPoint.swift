//
//  UserPoint.swift
//  SwipeShare
//
//  Created by Robbie Neuhaus on 2/4/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation
import MapKit

class UserPoint: NSObject, MKAnnotation {
    var title: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}