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
    guard let beaconLocation = beacon.location else { return -1 }
    
    let distance = location.distance(from: beaconLocation.clLocation)
    
    return distance
}
