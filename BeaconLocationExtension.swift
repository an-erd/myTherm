//
//  BeaconLocationExtension.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
//

import Foundation
import CoreLocation


extension BeaconLocation {

var location: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}

}

