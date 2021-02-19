//
//  BeaconLoation+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 17.02.21.
//
//

import Foundation
import CoreData


extension BeaconLoation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconLoation> {
        return NSFetchRequest<BeaconLoation>(entityName: "BeaconLoation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var beacon: Beacon?

}

extension BeaconLoation : Identifiable {

}
