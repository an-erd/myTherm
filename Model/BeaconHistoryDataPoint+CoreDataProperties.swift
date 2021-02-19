//
//  BeaconHistoryDataPoint+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 17.02.21.
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

}

extension BeaconHistoryDataPoint : Identifiable {

}
