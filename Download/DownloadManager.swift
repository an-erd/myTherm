//
//  BeaconBluetoothDownload.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreBluetooth
import CoreData
import SwiftUI
import os.signpost

enum DownloadManagerStatus{
    case idle, processing, done
}

class DownloadManager: NSObject, ObservableObject {
    private var localMoc: NSManagedObjectContext!
    private var viewMoc: NSManagedObjectContext!
    var activeDownloads: [Download] = []
    var activeDownload: Download?
    var status: DownloadManagerStatus = .idle
    
    func setMoc(localMoc: NSManagedObjectContext, viewMoc: NSManagedObjectContext) {
        self.localMoc = localMoc
        self.viewMoc = viewMoc
    }

    func addBeaconToDownloadQueue(uuid: UUID){
        localMoc.perform { [self] in
            print("DownloadManager queue len \(activeDownloads.count)")
            let activeDownloadsFiltered = activeDownloads.filter() {download in
                return download.uuid == uuid
            }
            if activeDownloadsFiltered.count > 0 {
                print("DownloadManager addBeaconToDownloadQueue beacon already in queue")
                return
            }
            
            if let beacon = MyCentralManagerDelegate.shared.fetchBeacon(context: localMoc, with: uuid) {
                let newDownload = Download(uuid: beacon.uuid!, beacon: beacon) // , delegate: beacon)
                activeDownloads.append(newDownload)
                
                resume()
            } else {
                print("addBeaconToDownloadQueue beacon not found in store")
            }
        }
    }
    
    func addAllBeaconsToDownloadQueue() {
        localMoc.perform { [self] in
            let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons(context: localMoc)
            for beacon in beacons {
                addBeaconToDownloadQueue(uuid: beacon.uuid!)
            }
        }
    }
    
    private func cleanupDownloadQueue() {
        let activeDownloadsFiltered = activeDownloads.filter() {download in
            return download.status == .waiting
        }
        if activeDownloadsFiltered.count == 0 {
            print("cleanupDownloadQueue")
            print("\(Thread.current)")
            for download in activeDownloads {
                download.status = DownloadStatus.waiting
            }
            localMoc.perform {
                self.activeDownloads.removeAll()
            }
        }
    }
    
    func resume() {
        localMoc.perform { [self] in
            print("DownloadManager resume() status \(status)")
            print("\(Thread.current)")
            switch status {
            case .idle:
                let activeDownloadsFiltered = activeDownloads.filter() {download in
                    return download.status == .waiting
                }
                print("DownloadManager resume() activeDownload waiting count \(activeDownloadsFiltered.count)")
                if activeDownloadsFiltered.count > 0 {
                    startDownload(download: activeDownloadsFiltered.first!)
                } else {
                    status = .done
                    resume()
                }
            case .processing:
                return
            case .done:
                cleanupDownloadQueue()
                status = .idle
                return
            }
        }
    }
    
    @objc
    private func connectTimerFire() {
        print("connectTimerFire")
        cancelDownload()
    }
    
    private func startDownload(download: Download) {
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
            MyBluetoothManager.shared.connectTimer =
                Timer.scheduledTimer(timeInterval: 10,
                                     target: self,
                                     selector: #selector(connectTimerFire),
                                     userInfo: nil, repeats: false)
        } else {
            print("no peripheral")
            download.status = .error
            activeDownload = nil
            MyBluetoothManager.shared.connectedPeripheral = nil
            self.status = .idle
        }
    }
    
    private func cancelDownload() {
        print("cancelDownload")
        if let connectedPeripheral = MyBluetoothManager.shared.connectedPeripheral{
            MyBluetoothManager.shared.central.cancelPeripheralConnection(connectedPeripheral)
            MyBluetoothManager.shared.connectedPeripheral = nil
            if let download = activeDownload {
                download.status = .error
            }
            activeDownload = nil
            self.status = .idle
            resume()
        }
    }
    
    func mergeHistoryToStore(uuid: UUID) {
        localMoc.perform { [self] in
            guard (activeDownload?.history) != nil else {
                print("mergeHistoryToStore downloadHistory error")
                return
            }
            
            guard let beacon = activeDownload?.beacon else {
                print("mergeHistoryToStore fetchBeacon error")
                return
            }
            
            let log = OSLog(
                subsystem: "com.anerd.myTherm",
                category: "download"
            )
            os_signpost(.begin, log: log, name: "mergeHistoryToStore")
            
            var dateLastHistoryEntry = Date.init(timeIntervalSince1970: 0)
            let historySorted = beacon.historyArray
//            print("history count before \(String(describing: historySorted.count))")
            
            if historySorted.count > 0 {
                dateLastHistoryEntry = historySorted.last!.wrappedTimeStamp
            }
            
            let downloadHistoryFiltered = activeDownload!.history.filter { dataPoint in
                return dataPoint.timestamp > dateLastHistoryEntry
            }
//            print("download history count \(String(describing: activeDownload!.history.count))")
//            print("download history filtered count \(String(describing: downloadHistoryFiltered.count))")
            
            for data in downloadHistoryFiltered {
                let newPoint = BeaconHistoryDataPoint(context: self.localMoc)        // TODO moc
                newPoint.humidity = data.humidity
                newPoint.temperature = data.temperature
                newPoint.timestamp = data.timestamp
                beacon.addToHistory(newPoint)
            }
            
            PersistenceController.shared.saveContext(context: self.localMoc)
            
            if let uuid = beacon.uuid {
                DispatchQueue.main.async {
                    MyCentralManagerDelegate.shared.copyHistoryArrayToLocalArray(context: viewMoc, uuid: uuid)
                }
            } else {
                    print("MyCentralManagerDelegate.shared.copyHistoryArrayToLocalArray uuid nil")
            }
            
            os_signpost(.end, log: log, name: "mergeHistoryToStore")
            
//            print("history count after \(String(describing: beacon.historyArray.count))")
//            print("Temp min \(beacon.temperatureArray.min() ?? -40) max \(beacon.temperatureArray.max() ?? -40)")
//            print("Humidity min \(beacon.humidityArray.min() ?? 0) max \(beacon.humidityArray.max() ?? 0)")
        }
    }
}
