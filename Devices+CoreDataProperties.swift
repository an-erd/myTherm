//
//  Devices+CoreDataProperties.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 02.05.21.
//
//

import Foundation
import CoreData


extension Devices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Devices> {
        return NSFetchRequest<Devices>(entityName: "Devices")
    }

    @NSManaged public var name: String?
    @NSManaged public var beacons: NSSet?

    public var beaconArray: [Beacon] {
        let set = beacons as? Set<Beacon> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
}

// MARK: Generated accessors for beacons
extension Devices {

    @objc(addBeaconsObject:)
    @NSManaged public func addToBeacons(_ value: Beacon)

    @objc(removeBeaconsObject:)
    @NSManaged public func removeFromBeacons(_ value: Beacon)

    @objc(addBeacons:)
    @NSManaged public func addToBeacons(_ values: NSSet)

    @objc(removeBeacons:)
    @NSManaged public func removeFromBeacons(_ values: NSSet)

}

extension Devices : Identifiable {

}
