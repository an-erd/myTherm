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
    case idle       // either no download upcoming or previous download completed and next one to start
    case processing // current download ongoing
    case error      // all downloads completed (no .waiting) but some with errors (-> handle/show message next)
    case done       // all downloads processed, possibly errors handled/shown, now cleanup and then back to .idle next
}

class DownloadManager: NSObject, ObservableObject {
    private var localMoc: NSManagedObjectContext!
    private var viewMoc: NSManagedObjectContext!
    var downloads: [Download] = []
    var activeDownload: Download?
    var status: DownloadManagerStatus = .idle
    
    static var shared = DownloadManager()
    private var beaconModel = BeaconModel.shared

    func setMoc(localMoc: NSManagedObjectContext, viewMoc: NSManagedObjectContext) {
        self.localMoc = localMoc
        self.viewMoc = viewMoc
    }

    func getDownload(with uuid: UUID) -> Download? {
        let downloadsFiltered = downloads.filter() {download in
            return download.uuid == uuid
        }
        if downloadsFiltered.count > 0 {
            return downloadsFiltered.first
        }
        return nil
    }
    
    func getDownloads(with status: DownloadStatus) -> [Download] {
        let downloadsFiltered = downloads.filter() {download in
            return download.status == status
        }
        
        if downloadsFiltered.count > 0 {
            return downloadsFiltered
        } else {
            return []
        }
    }
    
    func addBeaconToDownloadQueue(uuid: UUID){
        localMoc.perform { [self] in
            if getDownload(with: uuid) != nil {
                print("DownloadManager addBeaconToDownloadQueue beacon already in queue")
                return
            }
            
            if let beacon = beaconModel.fetchBeacon(context: localMoc, with: uuid) {
                let newDownload = Download(uuid: beacon.uuid!) // , delegate: beacon)
                downloads.append(newDownload)
                
                resume()
            } else {
                print("addBeaconToDownloadQueue beacon not found in store")
            }
        }
    }
    
    func addAllBeaconsToDownloadQueue() {
        localMoc.perform { [self] in
            let beacons: [Beacon] = beaconModel.fetchAllBeaconsFromStore(context: localMoc)
            for beacon in beacons {
                addBeaconToDownloadQueue(uuid: beacon.uuid!)
            }
        }
    }
    
    private func cleanupDownloadQueue() {
        print("cleanupDownloadQueue")
        localMoc.perform {
            self.downloads.removeAll()
        }
//        }
    }
    
    private func buildDownloadErrorStatus() -> (String, String, Int) {
        let count = getDownloads(with: .error).count
        let text1: String = "Download done"
        var text2: String = ""
        if count == 0 {
            text2 = "no errors"
        } else if count == 1 {
            text2 = "1 error"
        } else {
            text2 = "\(count) errors)"
        }
        return (text1, text2, count)
    }
    
    private func buildDownloadSuccessStatus() -> (String, String) {
        let text1: String = "Download done just now"
        let text2: String = ""
        return (text1, text2)
    }
    

    func buildDownloadErrorDeviceList() -> String {
        var text: String = ""
        localMoc.performAndWait {
            let downloadsError = getDownloads(with: .error)
            var counter = downloadsError.count
            for download in downloadsError {
                counter -= 1
                if let beacon = beaconModel.fetchBeacon(context: localMoc, with: download.uuid)  {
                    text.append("\(beacon.wrappedDeviceName) - \(beacon.wrappedName)")
                    if counter > 0 {
                        text.append("\n")
                    }
                }
            }
        }
        return text
    }
        
    func clearDownloadErrorAndResume() {
        DispatchQueue.main.async {
            BeaconModel.shared.isDownloadStatusError = false
        }
        localMoc.performAndWait {
            for download in self.downloads {
                download.status = .alldone
            }
            self.status = .done
            resume()
        }
    }
    
    func resume() {
        localMoc.perform { [self] in
            print("DownloadManager resume() > status \(status)")

            switch status {
            case .idle:
                let downloadsWaiting = getDownloads(with: .waiting)
                print("DownloadManager resume() activeDownload waiting count \(downloadsWaiting.count)")
                if downloadsWaiting.count > 0 {
                    startDownload(download: downloadsWaiting.first!)
                } else {
                    status = getDownloads(with: .error).count > 0 ? .error : .done
                    resume()
                }
            case .processing:
                // nothing to do, just let the download continue
                return
            case .error:
                print("resume .error")
                let (text1, text2, countError) = buildDownloadErrorStatus()
                DispatchQueue.main.async {
                    let model = BeaconModel.shared
                    model.numDownloadStatusError = countError
                    model.textDownloadStatusErrorLine1 = text1
                    model.textDownloadStatusErrorLine2 = text2
                    model.isDownloadStatusError = true
                }
                return
            case .done:
                print("resume .done")
                DispatchQueue.main.async {
                    let model = BeaconModel.shared
                    if model.numDownloadStatusError > 0 {
                        // do nothing but reset numDownloadStatusError, message already shown
                        model.numDownloadStatusError = 0
                    } else {
                        // show ready message with 5 sec timer
                        let (text1, text2) = buildDownloadSuccessStatus()
                        model.textDownloadingStatusLine1 = text1
                        model.textDownloadingStatusLine2 = text2
                        model.isDownloadStatusSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            model.isDownloadStatusSuccess = false
                        }
                    }
                }
                cleanupDownloadQueue()
                status = .idle
                return
            }
        }
    }
    
    @objc
    private func connectTimerFire() {
        print("connectTimerFire")
        localMoc.perform {
            self.cancelDownloadActive()
        }
    }
    
    private func startDownload(download: Download) {
        activeDownload = download
        
        download.status = .connecting
        MyCentralManagerDelegate.shared.updateBeaconDownloadStatus(context: viewMoc, with: download.uuid, status: .connecting)

        self.status = .processing
      
        let foundPeripherals = MyBluetoothManager.shared.central.retrievePeripherals(withIdentifiers: [download.uuid])
        MyBluetoothManager.shared.connectedPeripheral = foundPeripherals.first
        
        if let connectto = MyBluetoothManager.shared.connectedPeripheral {
            MyBluetoothManager.shared.central.connect(connectto, options: nil)
            DispatchQueue.main.async {
                MyBluetoothManager.shared.connectTimer =
                    Timer.scheduledTimer(timeInterval: 10,
                                         target: self,
                                         selector: #selector(self.connectTimerFire),
                                         userInfo: nil, repeats: false)
            }
        } else {
            print("no peripheral")
            download.status = .error
            activeDownload = nil
            MyBluetoothManager.shared.connectedPeripheral = nil
            self.status = .idle
        }
    }
    
    func cancelDownloadActive() {
        print("cancelDownloadActive")
        if let connectedPeripheral = MyBluetoothManager.shared.connectedPeripheral{
            MyBluetoothManager.shared.central.cancelPeripheralConnection(connectedPeripheral)
            MyBluetoothManager.shared.connectedPeripheral = nil
            if let download = activeDownload {
                MyCentralManagerDelegate.shared.updateBeaconDownloadStatus(context: viewMoc, with: download.uuid, status: .error)
                download.status = .error
            }
            activeDownload = nil
            self.status = .idle
            resume()
        }
    }

//    private func cancelDownloadCancelPressed() {
//        print("cancelDownloadCancelPressed")
//        if let connectedPeripheral = MyBluetoothManager.shared.connectedPeripheral{
//
//            MyBluetoothManager.shared.central.cancelPeripheralConnection(connectedPeripheral)
//            MyBluetoothManager.shared.connectedPeripheral = nil
//            if let download = activeDownload {
//                MyCentralManagerDelegate.shared.updateBeaconDownloadStatus(context: viewMoc, with: download.uuid, status: .error)
//                download.status = .cancelled
//            }
//            activeDownload = nil
//            self.status = .idle
//            resume()
//        }
//    }

    
    
    func cancelDownloadForUuid(uuid: UUID) {
        localMoc.perform { [self] in
            let activeDownloadsFiltered = downloads.filter() {download in
                return download.uuid == uuid
            }
            if activeDownloadsFiltered.count == 0 {
                print("cancelDownloadForUuid uuid not found")
                return
            }

            if let activeDownloadUuid = activeDownloadsFiltered.first {
                switch activeDownloadUuid.status {
                case .connecting, .downloading_num, .downloading_data:
                    if let timer = MyBluetoothManager.shared.connectTimer {
                        print("stopTimer because cancel active")
                        timer.invalidate()
                    }
                    if activeDownloadUuid.uuid == activeDownload!.uuid {
                        self.cancelDownloadActive()
                    } else {
                        print("cancelDownloadForUuid status mismatch!")
                    }
                    return
                case .waiting:
                    activeDownloadUuid.status = .cancelled
                    resume()
                default:
                    print("cancelDownloadForUuid default")
                }
            }
        }
    }
    
    func mergeHistoryToStore(uuid: UUID) {
        localMoc.perform { [self] in
            guard (activeDownload?.history) != nil else {
                print("mergeHistoryToStore downloadHistory error")
                return
            }
            
            guard let beacon = beaconModel.fetchBeacon(context: localMoc, with: uuid) else {
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
                    beaconModel.copyHistoryArrayToLocalArray(context: viewMoc, uuid: uuid)
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
