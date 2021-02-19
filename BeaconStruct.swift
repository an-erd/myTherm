//
//  BeaconStruct.swift
//  myTherm
//
//  Created by Andreas Erdmann on 18.02.21.
//

import Foundation

struct ExtractBeaconAdv {
    var temperature: Double
    var humidity: Double
    var battery: Int64
    var accel_x: Double
    var accel_y: Double
    var accel_z: Double
    var rawdata: String
}

struct ExtractBeacon {
    var beacon_version: Int16
    var company_id: Int16
    var id_maj: String
    var id_min: String
    var uuid: UUID?
    var name: String
    var descr: String
}
