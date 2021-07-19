//
//  BeaconModel.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 22.03.21.
//

import Foundation
import SwiftUI
import CoreData
import OSLog
import CoreHaptics

protocol BeaconModelDelegate {
    func changeDoScan(_ status: Bool)
    func changeDoUpdateAdv(_ status: Bool)
}

enum ActiveSheet: Identifiable {
    case filter, settings
    
    var id: Int {
        hashValue
    }
}

enum ActiveAlert: Identifiable {
    case downloadError
    case hiddenAlert
    
    var id: Int {
        hashValue
    }
}

final class BeaconModel: ObservableObject {
    
    var delegate: BeaconModelDelegate?

    static var shared = BeaconModel()

    @Published var isBluetoothAuthorization: Bool = true
    @Published var isShownTemperature: Bool = true
    
    @Published var isDownloading: Bool = false
    @Published var isDownloadStatusError: Bool = false
    @Published var isDownloadStatusSuccess: Bool = false
    
    @Published var textDownloadingStatusLine1: String = ""
    @Published var textDownloadingStatusLine2: String = ""

    @Published var numDownloadStatusError: Int = 0
    @Published var textDownloadStatusErrorLine1: String = ""
    @Published var textDownloadStatusErrorLine2: String = ""

    @Published var doScan: Bool = false
    @Published var doUpdateAdv: Bool = true
    @Published var scanTimerCounter: Double = 0    // counts down to 0 and then stop timer
    
    @Published var showAlert = false
    @Published var alert: Alert? = nil
    @Published var activeAlert: ActiveAlert?
    
    @Published var displaySteps: Int = 0
    
    @Published var isScrolling = false
    @Published var isScrollUpdate = false
    
    private var beaconCacheViewContext: [ UUID : Beacon ]  = [ : ]
    private var beaconCacheWriteContext: [ UUID : Beacon ] = [ : ]
    
    let log = OSLog(subsystem: "com.anerd.myTherm", category: "preparation")

    private init() {
        print("init BeaconModel")
        checkAndInitStructures(context: PersistenceController.shared.writeContext)
        setInitBeaconDownloadStatus(context: PersistenceController.shared.writeContext)
        initLocalBeaconCache(writeContext: PersistenceController.shared.writeContext, viewContext: PersistenceController.shared.viewContext)
        printDevicesAndBeacons(context: PersistenceController.shared.writeContext)
    }
    
    func addBeaconToDevices(context: NSManagedObjectContext, beacon: Beacon) {
        if let devices = fetchDevices(context: context) {
            if beacon.devices != nil {
                print("beacon \(beacon.wrappedDeviceName) devices not nil!")
                return
            }
            devices.addToBeacons(beacon)
            print("addBeaconToDevices beacon \(beacon.wrappedDeviceName) beaconArray.count \(devices.beaconArray.count) beacon objID \(beacon.objectID) device objID objectID \(devices.objectID)")
        }
    }

    func checkAndInitStructures(context: NSManagedObjectContext) {
        context.performAndWait { [self] in
            let devices = fetchDevices(context: context)
            if devices == nil {
                print("checkAndInitStructures no Devices found, creating new one")
                let newDevices = Devices(context: context)
                newDevices.name = "devices"
                let beacons = fetchAllBeaconsFromStore(context: context)
                for beacon in beacons {
                    if beacon.devices == nil {
                        print("checkAndInitStructures assigning beacon \(beacon.wrappedDeviceName) to new Devices")
                        beacon.devices = newDevices
                    }
                }
                PersistenceController.shared.saveContext(context: context)
            }
        }
    }
    
    func initLocalBeaconCache(writeContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) {
        writeContext.performAndWait {
            os_signpost(.begin, log: self.log, name: "localCache", "fetch_writeCtx")
            let beacons = fetchAllBeaconsFromStore(context: writeContext)
            for beacon in beacons {
                beaconCacheWriteContext[beacon.uuid!] = beacon
            }
            os_signpost(.end, log: self.log, name: "localCache", "fetch_writeCtx")
        }

        viewContext.performAndWait {
            os_signpost(.begin, log: self.log, name: "localCache", "fetch_viewCtx")
            let beacons = fetchAllBeaconsFromStore(context: viewContext)
            for beacon in beacons {
                beaconCacheViewContext[beacon.uuid!] = beacon
            }
            os_signpost(.end, log: self.log, name: "localCache", "fetch_viewCtx")
        }
    }
//os_signpost(.begin, log: self.log, name: "localCache", "fetch_%{public}s", beacon.wrappedDeviceName)

    func setInitBeaconDownloadStatus(context: NSManagedObjectContext) {
        context.perform { [self] in
            let beacons = fetchAllBeaconsFromStore(context: context)
            for beacon in beacons {
                beacon.localDownloadStatus = .none                
            }
        }
    }

    func printDevicesAndBeacons(context: NSManagedObjectContext) {
        context.perform { [self] in
            let devices = fetchDevices(context: context)
            if let devices = devices {
                print("printDevicesAndBeacons devices.count beaconArray.count \(devices.beaconArray.count)")
                for beacon in devices.beaconArray {
                    let advSet = (beacon.adv != nil ? "y" : "n")
                    print("  \(beacon.wrappedDeviceName) adv set \(advSet)")
                }
            }
            
            print("beacons w/o devices")
            let beacons = fetchAllBeaconsFromStore(context: context)
            for beacon in beacons {
                if beacon.devices == nil {
                    print("  \(beacon.wrappedDeviceName)")
                }
            }
        }
    }
        
    func fetchDevices(context: NSManagedObjectContext) -> Devices? {
        let fetchRequest: NSFetchRequest<Devices> = Devices.fetchRequest()
        var devices: [Devices] = []
        do {
            devices = try context.fetch(fetchRequest)
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
            return nil
        }
        return devices.first ?? nil
    }
     
    func fetchBeacon(context: NSManagedObjectContext, with identifier: UUID) -> Beacon? {
        let useViewCtx: Bool = context == PersistenceController.shared.viewContext
        if useViewCtx {
            if let beacon = beaconCacheViewContext[identifier] {
                return beacon
            }
        }

//        print("fetchBeacon \(useViewCtx ? "view" : "other")")
        
        let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "uuid", identifier as CVarArg)
        do {
            let beacons: [Beacon] = try context.fetch(fetchRequest)
            if let beacon = beacons.first {
                os_signpost(.event, log: self.log, name: "fetch", "fetch_%{public}s", beacon.wrappedDeviceName)
            }
            return beacons.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }
    
    func fetchAllBeaconsFromStore(context: NSManagedObjectContext) -> [Beacon] {
        let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
        do {
            let beacons: [Beacon] = try context.fetch(fetchRequest)
            return beacons
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        return []
    }

    func deleteHistory(context: NSManagedObjectContext) {
        let moc = PersistenceController.shared.newTaskContext()
        moc.perform {
            print("deleteHistory")
            do {
                try self.deleteHistory(in: moc)
            } catch let error as NSError  {
                print("Could not delete history \(error), \(error.userInfo)")
            }
            PersistenceController.shared.saveContext(context: moc)
        }
    }

    public func deleteHistory(in context: NSManagedObjectContext) throws {
        guard #available(iOSApplicationExtension 11.0, *) else { return }

        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -7

        guard let timestamp = Calendar.current.date(byAdding: dateComponent, to: currentDate) else { return }
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try! context.execute(deleteHistoryRequest)
    }
    
    public func copyHistoryArrayToLocalArray(context: NSManagedObjectContext, uuid: UUID) {
        context.performAndWait {
            if let beacon = fetchBeacon(context: context, with: uuid) {
                print("BeaconModel copyHistoryArrayToLocalArray \(beacon.wrappedDeviceName) ")
                beacon.copyHistoryArrayToLocalArray()

            } else {
                print("copyHistoryArrayToLocalArray beacon not found")
            }
        }
    }
    
    public func copyLocalHistoryArrayBetweenContext(
        contextFrom: NSManagedObjectContext, contextTo: NSManagedObjectContext, uuid: UUID) {
        print("copyLocalHistoryArrayBetweenContext 1 \(Thread.current)")
        var tempHistoryTemperature: [Double]!
        var tempHistoryHumidity: [Double]!
        var tempHistoryTimestamp: [Date]!
        
        contextFrom.performAndWait {
            print("copyLocalHistoryArrayBetweenContext 2 \(Thread.current)")
            if let beacon = fetchBeacon(context: contextFrom, with: uuid) {
                tempHistoryTemperature = beacon.localHistoryTemperature
                tempHistoryHumidity = beacon.localHistoryHumidity
                tempHistoryTimestamp = beacon.localHistoryTimestamp
            }
        }
        
        DispatchQueue.main.async {
            contextTo.performAndWait {
                print("copyLocalHistoryArrayBetweenContext 3 \(Thread.current)")
                if let beacon = self.fetchBeacon(context: contextTo, with: uuid) {
                    beacon.localHistoryTemperature = tempHistoryTemperature
                    beacon.localHistoryHumidity = tempHistoryHumidity
                    beacon.localHistoryTimestamp = tempHistoryTimestamp
                }
            }
        }
    }
    
    public func copyBeaconHistoryOnce(contextFrom: NSManagedObjectContext, contextTo: NSManagedObjectContext) {
        print("copyBeaconHistoryOnce")

        os_signpost(.begin, log: log, name: "copyBeaconHistoryOnce")
        let beacons = fetchAllBeaconsFromStore(context: contextFrom)
        for beacon in beacons {
            let uuid: UUID = beacon.uuid!
            os_signpost(.begin, log: log, name: "copyBeaconHistory", "%{public}s", beacon.wrappedDeviceName)
            copyBeaconHistory(contextFrom: contextFrom, contextTo: contextTo, uuid: uuid)
            os_signpost(.end, log: log, name: "copyBeaconHistory", "%{public}s", beacon.wrappedDeviceName)
        }
        os_signpost(.end, log: log, name: "copyBeaconHistoryOnce")
    }
    
    public func copyBeaconHistory(contextFrom: NSManagedObjectContext, contextTo: NSManagedObjectContext, uuid: UUID) {
        print("copyBeaconHistory")
        
        copyHistoryArrayToLocalArray(context: contextFrom, uuid: uuid)
        copyLocalHistoryArrayBetweenContext(contextFrom: contextFrom, contextTo: contextTo, uuid: uuid)
    }
    
    public func copyLocalBeaconsToWriteContext() {
        print("copyLocalBeaconsToWriteContext")
        print("\(Thread.current)")  // must be on main!
        
        struct CopyOfBeacon {
            var uuid: UUID
            var changesBeacon: CopyBeacon?
            var changesAdv: CopyBeaconAdv?
            var changesLoc: CopyBeaconLoc?
        }
        
        var copyOfAllBeacons: [ CopyOfBeacon ] = []
        
        let viewMoc = PersistenceController.shared.viewContext
        viewMoc.performAndWait {
            let fromBeacons = fetchAllBeaconsFromStore(context: viewMoc)
            for fromBeacon in fromBeacons {
                if let uuid = fromBeacon.uuid {
                    var localChanges = CopyOfBeacon(uuid: uuid)
                    
                    if fromBeacon.changedValues().count > 0 {
                        localChanges.changesBeacon = fromBeacon.copyContent()
                    }
                    
                    if let fromAdv = fromBeacon.adv {
                        if fromAdv.changedValues().count > 0 {
                            localChanges.changesAdv = fromAdv.copyContent()
                        }
                    }
                    
                    if let fromLocation = fromBeacon.location {
                        if fromLocation.changedValues().count > 0 {
                            localChanges.changesLoc = fromLocation.copyContent()
                        }
                    }
                    copyOfAllBeacons.append(localChanges)
                }
            }
        }
        
        let queue = DispatchQueue(label: "CentralManager")
        queue.async { [self] in
            let moc = PersistenceController.shared.newTaskContext()
            moc.performAndWait {
                for copy in copyOfAllBeacons {
                    if let toBeacon = fetchBeacon(context: moc, with: copy.uuid) {
                        if let changesBeacon = copy.changesBeacon {
                            toBeacon.copyContent(from: changesBeacon)
                        }
                        if let changesAdv = copy.changesAdv {
                            if toBeacon.adv != nil { } else {
                                toBeacon.adv = BeaconAdv(context: moc)
                            }
                            if let toAdv = toBeacon.adv {
                                toAdv.copyContent(from: changesAdv)
                            }
                        }
                        if let changesLoc = copy.changesLoc {
                            if toBeacon.location != nil { } else {
                                toBeacon.location = BeaconLocation(context: moc)
                            }
                            if let toLocation = toBeacon.location {
                                toLocation.copyContent(from: changesLoc)
                            }
                        }
                    }
                }
                PersistenceController.shared.saveContext(context: moc)
            }
        }
    }

}
