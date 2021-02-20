//
//  BeaconLocation+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
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

}

extension BeaconLocation : Identifiable {

}
