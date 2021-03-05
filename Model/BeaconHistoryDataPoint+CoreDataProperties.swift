//
//  BeaconHistoryDataPoint+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
//
//

import Foundation
import CoreData


extension BeaconHistoryDataPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconHistoryDataPoint> {
        return NSFetchRequest<BeaconHistoryDataPoint>(entityName: "BeaconHistoryDataPoint")
    }

    @NSManaged public var humidity: Double
    @NSManaged public var temperature: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var beacon: Beacon?

    public var wrappedTimeStamp: Date {
        timestamp ?? Date(timeIntervalSince1970: 0)
    }
}

extension BeaconHistoryDataPoint : Identifiable {

}
