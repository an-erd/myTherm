//
//  BeaconBluetoothDownload.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreBluetooth
import CoreData

enum DownloadManagerStatus{
    case idle, getCount, downloading, processing, done, cancel
}

class DownloadManager: NSObject, ObservableObject {
    private var moc: NSManagedObjectContext!
    var downloadHistory: Download?
//    var activeDownloads: [Download] = []    // FIFO
//    var downloadManagerStatus: DownloadManagerStatus = .idle
    
    func setMoc(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    func downloadHistoryFromBeacon(uuid: UUID)  {
        let foundPeripherals =
            MyBluetoothManager.shared.central.retrievePeripherals(withIdentifiers: [uuid])

        print("printPeripherals:")
        print(foundPeripherals)

        MyBluetoothManager.shared.connectedPeripheral = foundPeripherals.first
        if let connectto = MyBluetoothManager.shared.connectedPeripheral {
            downloadHistory = Download(uuid: uuid)
            if let downloadHistory = downloadHistory {
                downloadHistory.status = .connecting
                MyBluetoothManager.shared.central.connect(connectto, options: nil)
            }
        } else {
            print("no peripheral")
        }
    }

    func mergeHistoryToStore(uuid: UUID) {
        guard let downloadHistory = downloadHistory else {
            print("mergeHistoryToStore downloadHistory error")
            return
        }
        
        guard let beacon = MyCentralManagerDelegate.shared.fetchBeacon(with: downloadHistory.uuid) else {
            print("mergeHistoryToStore fetchBeacon error")
            return
        }

        var dateLastHistoryEntry = Date.init(timeIntervalSince1970: 0)
        let historySorted = beacon.historyArray
        print("history count before \(String(describing: historySorted.count))")

        if historySorted.count > 0 {
            dateLastHistoryEntry = historySorted.last!.wrappedTimeStamp
        }

        let downloadHistoryFiltered = downloadHistory.history.filter { dataPoint in
            return dataPoint.timestamp > dateLastHistoryEntry
        }
        print("download history count \(String(describing: downloadHistory.history.count))")
        print("download history filtered count \(String(describing: downloadHistoryFiltered.count))")

        for data in downloadHistoryFiltered {
            let newPoint = BeaconHistoryDataPoint(context: self.moc)
            newPoint.humidity = data.humidity
            newPoint.temperature = data.temperature
            newPoint.timestamp = data.timestamp
            beacon.addToHistory(newPoint)
        }
        PersistenceController.shared.saveBackgroundContext(backgroundContext: self.moc)

        print("history count after \(String(describing: beacon.historyArray.count))")
        
        print("Temp min \(beacon.temperatureArray.min()) max \(beacon.temperatureArray.max())")
        print("Humidity min \(beacon.humidityArray.min()) max \(beacon.humidityArray.max())")
    }
}

