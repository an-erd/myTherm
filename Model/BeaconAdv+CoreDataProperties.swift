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

    public func copyContent(from: BeaconAdv) {
        self.accel_x = from.accel_x
        self.accel_y = from.accel_y
        self.accel_z = from.accel_z
        self.battery = from.battery
        self.humidity = from.humidity
        self.rawdata = from.rawdata
        self.rssi = from.rssi
        self.temperature = from.temperature
        self.timestamp = from.timestamp
    }
    
    public func copyContent() -> CopyBeaconAdv {
        return CopyBeaconAdv(
            accel_x: self.accel_x, accel_y: self.accel_y, accel_z: self.accel_z,
            battery: self.battery, humidity: self.humidity, rawdata: self.rawdata, rssi: self.rssi,
            temperature: self.temperature, timestamp: self.timestamp)
    }
    
    public func copyContent(from: CopyBeaconAdv) {
        self.accel_x = from.accel_x
        self.accel_y = from.accel_y
        self.accel_z = from.accel_z
        self.battery = from.battery
        self.humidity = from.humidity
        self.rawdata = from.rawdata
        self.rssi = from.rssi
        self.temperature = from.temperature
        self.timestamp = from.timestamp
    }
}

extension BeaconAdv : Identifiable {

}
