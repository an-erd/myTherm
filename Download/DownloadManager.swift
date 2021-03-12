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
    case idle, processing
}

class DownloadManager: NSObject, ObservableObject {
    private var moc: NSManagedObjectContext!
//    var downloadHistory: Download?
    var activeDownloads: [Download] = []
    var activeDownload: Download?
    var status: DownloadManagerStatus = .idle
//    var counterControlPointNotification = 0
//    var counterMeasurementValueNotification = 0
    
    func setMoc(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func addBeaconToDownloadQueue(beacon: Beacon){
        print("DownloadManager queue len \(activeDownloads.count)")
        let activeDownloadsFiltered = activeDownloads.filter() {download in
            return download.uuid == beacon.uuid
        }
        if activeDownloadsFiltered.count > 0 {
            print("DownloadManager addBeaconToDownloadQueue beacon already in queue")
            return
        }
        
        let newDownload = Download(uuid: beacon.uuid!, beacon: beacon, delegate: beacon)
        activeDownloads.append(newDownload)
        
        resume()
    }
    
    func addAllBeaconToDownloadQueue() {
        let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons()
        for beacon in beacons {
            addBeaconToDownloadQueue(beacon: beacon)
        }
    }
    
    func resume() {
        print("DownloadManager resume() status \(status)")
        switch status {
        case .idle:
            let activeDownloadsFiltered = activeDownloads.filter() {download in
                return download.status == .waiting
            }
            print("DownloadManager resume() activeDownload waiting count \(activeDownloadsFiltered.count)")
            if activeDownloadsFiltered.count > 0 {
                startDownload(download: activeDownloadsFiltered.first!)
            }
        case .processing:
            return
        }
    }
    
    func startDownload(download: Download) {
        download.status = .connecting
        activeDownload = download
        self.status = .processing
        
        print("DownloadManager startDownload beacon \(activeDownload?.beacon?.wrappedName ?? "no beacon")")
       
        let foundPeripherals =
            MyBluetoothManager.shared.central.retrievePeripherals(withIdentifiers: [download.uuid])
//        print("printPeripherals:")
//        print(foundPeripherals)
        MyBluetoothManager.shared.connectedPeripheral = foundPeripherals.first
        if let connectto = MyBluetoothManager.shared.connectedPeripheral {
            MyBluetoothManager.shared.central.connect(connectto, options: nil)
        } else {
            print("no peripheral")
            download.status = .error
            activeDownload = nil
            self.status = .idle
        }
    }

    func mergeHistoryToStore(uuid: UUID) {
        guard (activeDownload?.history) != nil else {
            print("mergeHistoryToStore downloadHistory error")
            return
        }
        
        guard let beacon = activeDownload?.beacon else {
            print("mergeHistoryToStore fetchBeacon error")
            return
        }

        var dateLastHistoryEntry = Date.init(timeIntervalSince1970: 0)
        let historySorted = beacon.historyArray
        print("history count before \(String(describing: historySorted.count))")

        if historySorted.count > 0 {
            dateLastHistoryEntry = historySorted.last!.wrappedTimeStamp
        }

        let downloadHistoryFiltered = activeDownload!.history.filter { dataPoint in
            return dataPoint.timestamp > dateLastHistoryEntry
        }
        print("download history count \(String(describing: activeDownload!.history.count))")
        print("download history filtered count \(String(describing: downloadHistoryFiltered.count))")

        for data in downloadHistoryFiltered {
            let newPoint = BeaconHistoryDataPoint(context: self.moc)
            newPoint.humidity = data.humidity
            newPoint.temperature = data.temperature
            newPoint.timestamp = data.timestamp
            beacon.addToHistory(newPoint)
        }
        PersistenceController.shared.saveBackgroundContext(backgroundContext: self.moc)
        beacon.copyHistoryArrayToLocalArray()
        
        print("history count after \(String(describing: beacon.historyArray.count))")
        
        print("Temp min \(beacon.temperatureArray.min() ?? -40) max \(beacon.temperatureArray.max() ?? -40)")
        print("Humidity min \(beacon.humidityArray.min() ?? 0) max \(beacon.humidityArray.max() ?? 0)")
    }
}

