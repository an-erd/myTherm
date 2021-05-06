//
//  Download.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation
import CoreData

public enum DownloadStatus: Int32 {
    case none                   = 0 // no active download
    case waiting                = 1 // in queue and waiting for next action: download
    case connecting             = 2 // in progress of connecting to device
    case downloading_num        = 3 // in progress of getting overall number of entries to download
    case downloading_data       = 4 // in progress of retrievin data
    case downloading_finished   = 5 // downloading has been finished
    case alldone                = 6 // status is all errors had been shown and cleared
    case cancelled              = 7 // download has been canceled by the user
    case error                  = 8 // error connecting to or retrieving data from device
}

class Download : ObservableObject {
    var uuid: UUID
//    var beacon: Beacon?
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
        

    init(uuid: UUID) {
        self.uuid = uuid
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    deinit {
        let newUuid = self.uuid
        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            MyCentralManagerDelegate.shared.updateBeaconDownloadProgress(context: moc, with: newUuid, progress: 0.0)
            MyCentralManagerDelegate.shared.updateBeaconDownloadStatus(context: moc, with: newUuid, status: .none)
        }
    }
    
    public var historySorted: [BeaconHistoryDataPointLocal] {
        return history.sorted {
            $0.timestamp < $1.timestamp
        }
    }
        
}
