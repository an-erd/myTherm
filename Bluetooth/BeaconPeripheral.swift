//
//  BeaconPeripheralServices.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreBluetooth

class BeaconPeripheral: NSObject {
    public static let beaconRemoteServiceUUID               = CBUUID.init(string: "612F1400-37F5-4C4F-9FF2-320C4BA2B73C")
    public static let beaconRACPMeasurementValuesCharUUID   = CBUUID.init(string: "1401")
    public static let beaconRACPControlPointCharUUID        = CBUUID.init(string: "2A52")
}
