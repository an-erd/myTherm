//
//  Beacon+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 19.02.21.
//
//

import Foundation
import CoreData


extension Beacon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beacon> {
        return NSFetchRequest<Beacon>(entityName: "Beacon")
    }

    @NSManaged public var beacon_version: Int16
    @NSManaged public var company_id: Int16
    @NSManaged public var descr: String?
    @NSManaged public var id_maj: String?
    @NSManaged public var id_min: String?
    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var device_name: String?
    @NSManaged public var adv: BeaconAdv?
    @NSManaged public var history: NSSet?
    @NSManaged public var location: BeaconLocation?

}

// MARK: Generated accessors for history
extension Beacon {

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: BeaconHistoryDataPoint)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: BeaconHistoryDataPoint)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSSet)

}

extension Beacon : Identifiable {

}
