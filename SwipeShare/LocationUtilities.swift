//
//  LocationUtilities.swift
//  SwipeShare
//
//  Created by Troy Palmer on 5/16/16.
//  Copyright © 2016 yaw. All rights reserved.
//

import Foundation

class LocationUtilities {
    
    var latSearchDistance = 0.001
    var longSearchDistance = 0.001
    var searchDistance = 0.001
    var earthRadius = 6371.0
    var ftInMiles = 5280.0
    
    var milesToKM = 0.621371
    var distanceToLat = 110.574
    var distanceToLong = 111.320
    
    
    /********************DISTANCE AND BEARING CALCULATIONS********************/
    
    
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
    
}