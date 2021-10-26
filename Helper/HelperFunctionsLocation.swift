//
//  HelperFunctionsLocation.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 12.04.21.
//

import Foundation
import CoreLocation

func distanceFromPosition(location: CLLocation?, beacon: Beacon ) -> Double {
    guard let location = location else { return -1 }
    
    if beacon.location.locationAvailable == true {
        return -1
    }

    return location.distance(from: beacon.location.clLocation)
}
