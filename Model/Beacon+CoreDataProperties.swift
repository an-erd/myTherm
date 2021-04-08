//
//  Beacon+CoreDataProperties.swift
//  myTherm
//
//  Created by Andreas Erdmann on 03.03.21.
//
//

import Foundation
import CoreData


extension Beacon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beacon> {
        return NSFetchRequest<Beacon>(entityName: "Beacon")
    }

    @NSManaged public var beacon_version: Int16
    @NSManaged public var company_id: Int16
    @NSManaged public var descr: String?
    @NSManaged public var device_name: String?
    @NSManaged public var id_maj: String?
    @NSManaged public var id_min: String?
    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var flag: Bool
    @NSManaged public var adv: BeaconAdv?
    @NSManaged public var history: NSSet?
    @NSManaged public var location: BeaconLocation?
    @NSManaged public var localTimestamp: Date?
    @NSManaged public var localDistanceFromPosition: Double
    @NSManaged public var localHistoryTemperature: [Double]?
    @NSManaged public var localHistoryHumidity: [Double]?
    @NSManaged public var localHistoryTimestamp: [Date]?
    @NSManaged public var localDownloadProgress: Float
    @NSManaged public var localDownloadStatusValue: Int32
    @NSManaged public var localAdv: BeaconAdv?
    @NSManaged public var localLocation: BeaconLocation?
    
    public var localDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: self.localDownloadStatusValue)!
        }
        set {
            self.localDownloadStatusValue = newValue.rawValue
        }
    }

    public var wrappedDescr: String {
        descr ?? "no description"
    }
    
    public var wrappedDeviceName: String {
        device_name ?? "no device name"
    }
    
    public var wrappedIdMaj: String {
        id_maj ?? "00"
    }
    
    public var wrappedIdMin: String {
        id_min ?? "00"
    }
    
    public var wrappedName: String {
        name ?? "no name"
    }
    
    public var wrappedLocalHistoryTemperature: [Double] {
        guard localHistoryTemperature != nil else {
            print("wrappedLocalHistoryTemperature \(self.wrappedDeviceName) guard localHistoryTemperature != nil")
            return []
        }
        return localHistoryTemperature!
    }
    
    public var wrappedLocalHistoryHumidity: [Double] {
        guard localHistoryHumidity != nil else { return [] }
        return localHistoryHumidity!
    }
    
    public var wrappedLocalHistoryTimestamp: [Date] {
        guard localHistoryTimestamp != nil else { return [] }
        return localHistoryTimestamp!
    }
    

    public var historyArray: [BeaconHistoryDataPoint] {
        let set = history as? Set<BeaconHistoryDataPoint> ?? []
        if let history = history {
            print("\(self.wrappedDeviceName) historyArray.count() \(history.count)")
        }
        return set.sorted {
            $0.wrappedTimeStamp < $1.wrappedTimeStamp
        }
    }

    public var temperatureArray: [Double] {
        let new = historyArray.suffix(576).map { Double($0.temperature) }
        print("\(self.wrappedDeviceName) temperatureArray.count() = \(new.count)")
        if new.count ==  0 {
            return []
        }
//        print("Beacon get temperatureArray \(Date())")
        return new
    }
    
    public var humidityArray: [Double] {
        let new = historyArray.suffix(576).map { Double($0.humidity) }
        
        if new.count ==  0 {
            return []
        }
        return new
    }
    
    public var dateArray: [Date] {
        let dates = historyArray.suffix(576).map { $0.timestamp! }
        
        if dates.count == 0 {
            return []
        }
        return dates
    }

    public func wrappedAdvDateInterpretation(nowDate: Date) -> String {
        guard let beaconadv = self.adv else { return "never" }
        guard let date = beaconadv.timestamp else { return "not available" }
        return getDateInterpretationString(date: date, nowDate: nowDate)
    }
    
    public func wrappedLocalAdvDateInterpretation(nowDate: Date) -> String {
        guard let beaconadv = self.localAdv else { return "never" }
        guard let date = beaconadv.timestamp else { return "not available" }
        return getDateInterpretationString(date: date, nowDate: nowDate)
    }

    public var historyCount: Int {
        guard let history = self.history else { return 0 }
        return history.count
    }
}

// MARK: Generated accessors for history
extension Beacon {

    @objc(insertObject:inHistoryAtIndex:)
    @NSManaged public func insertIntoHistory(_ value: BeaconHistoryDataPoint, at idx: Int)

    @objc(removeObjectFromHistoryAtIndex:)
    @NSManaged public func removeFromHistory(at idx: Int)

    @objc(insertHistory:atIndexes:)
    @NSManaged public func insertIntoHistory(_ values: [BeaconHistoryDataPoint], at indexes: NSIndexSet)

    @objc(removeHistoryAtIndexes:)
    @NSManaged public func removeFromHistory(at indexes: NSIndexSet)

    @objc(replaceObjectInHistoryAtIndex:withObject:)
    @NSManaged public func replaceHistory(at idx: Int, with value: BeaconHistoryDataPoint)

    @objc(replaceHistoryAtIndexes:withHistory:)
    @NSManaged public func replaceHistory(at indexes: NSIndexSet, with values: [BeaconHistoryDataPoint])

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: BeaconHistoryDataPoint)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: BeaconHistoryDataPoint)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSOrderedSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSOrderedSet)

}

extension Beacon : Identifiable {
    public func copyHistoryArrayToLocalArray() {
        print("copyHistoryArrayToLocalArray \(self.wrappedDeviceName)")
        self.localHistoryTemperature = self.temperatureArray
        self.localHistoryHumidity = self.humidityArray
        self.localHistoryTimestamp = self.dateArray
    }
}

//extension Beacon : DownloadDelegate {
//    
//    func downloadProgressUpdated(for progress: Float, for uuid: UUID) {
//        self.localDownloadProgress = progress
//    }
//    
//    func downloadStatusUpdated(for status: DownloadStatus, for uuid: UUID) {
//        self.localDownloadStatus = status
//        print("downloadStatusUpdated for \(self.wrappedDeviceName) to \(status)")
//    }
//    
//}
