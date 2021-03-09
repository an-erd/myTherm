//
//  BeaconAdv+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
//
//

import Foundation
import CoreData


extension BeaconAdv {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconAdv> {
        return NSFetchRequest<BeaconAdv>(entityName: "BeaconAdv")
    }

    @NSManaged public var accel_x: Double
    @NSManaged public var accel_y: Double
    @NSManaged public var accel_z: Double
    @NSManaged public var battery: Int64
    @NSManaged public var humidity: Double
    @NSManaged public var rawdata: String?
    @NSManaged public var rssi: Int64
    @NSManaged public var temperature: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var beacon: Beacon?
    @NSManaged public var localHistoryTemperature: [Double]?
    @NSManaged public var localHistoryHumidity: [Double]?


}

extension BeaconAdv : Identifiable {

}
