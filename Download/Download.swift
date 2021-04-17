//
//  Download.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreData

public enum DownloadStatus: Int32 {
    case waiting = 0                // in queue and waiting for next action: download
    case connecting = 1             // in progress of connecting to device
    case downloading_num = 2        // in progress of getting overall number of entries to download
    case downloading_data = 3       // in progress of retrievin data
    case downloading_finished = 4   // downloading has been finished
    case alldone = 5                // TODO what is alldone, should be removed
    case cancelled = 6              // download has been canceled by the user
    case error = 7                  // error connecting to or retrieving data from device
    case none = 8                   // TODO should be removed
}

class Download : ObservableObject {
    var uuid: UUID
    var beacon: Beacon?
    var viewContext: NSManagedObjectContext
    var status: DownloadStatus = .waiting
//    {
//        get {
////            var newStatus: DownloadStatus = .none
////            viewContext.performAndWait {
//                return DownloadStatus(rawValue: beacon!.localDownloadStatus.rawValue)!
////            }
////            return newStatus
//        }
//        set {
////            var newStatusRaw = newValue.rawValue
////            viewContext.performAndWait {
//            beacon!.localDownloadStatusValue = newValue.rawValue
////            }
//        }
//    }

    var progress: Float = 0.0
//    {
//        get {
//            var newProgress: Float = 0.0
//            viewContext.performAndWait {
//                newProgress = beacon!.localDownloadProgress
//            }
//            return newProgress
//        }
//        set {
//            viewContext.performAndWait {
//                beacon!.localDownloadProgress = newValue
//            }
//        }
//    }

    var numEntriesAll: Int = 0
    var numEntriesReceived: Int = 0
    var history: [BeaconHistoryDataPointLocal] = []
        

    init(uuid: UUID, beacon: Beacon) {
        self.uuid = uuid
        self.beacon = beacon
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    deinit {
        let newUuid = self.uuid
        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            MyCentralManagerDelegate.shared.updateBeaconDownloadProgress(context: moc, with: newUuid, progress: 0.0)
            MyCentralManagerDelegate.shared.updateBeaconDownloadStatus(context: moc, with: newUuid, status: .waiting)
        }
    }
    
    public var historySorted: [BeaconHistoryDataPointLocal] {
        return history.sorted {
            $0.timestamp < $1.timestamp
        }
    }
        
}
