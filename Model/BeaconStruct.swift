//
//  BeaconStruct.swift
//  myTherm
//
//  Created by Andreas Erdmann on 18.02.21.
//

import Foundation
import SwiftUI

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

struct BeaconHistoryDataPointLocal : Hashable{
    var sequenceNumber: UInt16
    var humidity: Double
    var temperature: Double
    var timestamp: Date
}

class BeaconLocalValueView : ObservableObject {
//    @Published var isTabbing: Bool = false
    @Published var isDragging: Bool = false
    @Published var firstTouchLocation: CGFloat = 0
    @Published var timestamp: Date?
    @Published var temperature: Double = 0
    @Published var humidity: Double = 0
}
