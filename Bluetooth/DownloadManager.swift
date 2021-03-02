//
//  BeaconBluetoothDownload.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreBluetooth

enum DownloadManagerStatus {
    case idle, getCount, downloading, processing, done, cancel
}

class DownloadManager: NSObject, ObservableObject {

    var activeDownloads: [Download] = []    // FIFO
    var downloadManagerStatus: DownloadManagerStatus = .idle
    
    var countControlPointNotification = 0
    var countMeasurementValueNotification = 0
    
}



var connectedPeripheral: CBPeripheral?

func printPeripherals(uuid: UUID)  {
    let foundPeripherals =
        MyBluetoothManager.shared.central.retrievePeripherals(withIdentifiers: [uuid])

    print("printPeripherals:")
    print(foundPeripherals)

    connectedPeripheral = foundPeripherals.first
    if let connectto = connectedPeripheral {
        MyBluetoothManager.shared.central.connect(connectto, options: nil)
    } else {
        print("no peripheral")
    }
}

