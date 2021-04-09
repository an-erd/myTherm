//
//  BeaconLocation+CoreDataProperties.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 08.03.21.
//
//

import Foundation
import CoreData


extension BeaconLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconLocation> {
        return NSFetchRequest<BeaconLocation>(entityName: "BeaconLocation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var beacon: Beacon?

    public func copyContent(from: BeaconLocation) {
        self.latitude = from.latitude
        self.longitude = from.longitude
        self.timestamp = from.timestamp
        self.beacon = from.beacon
    }

}

extension BeaconLocation : Identifiable {

}
