//
//  Download.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation

protocol DownloadDelegate: AnyObject {
    func downloadProgressUpdated(for progress: Float)
}

enum DownloadStatus {
    case waiting, connecting, downloading_num, downloading_data, downloading_finished, alldone, cancelled
}

class Download {

    weak var delegate: DownloadDelegate?
    
    var uuid: UUID
    var status: DownloadStatus = .waiting
    var numEntriesAll: Int = 0
    var numEntriesReceived: Int = 0
    var history: [BeaconHistoryDataPointLocal] = []
        
    var progress: Float = 0.0 {
        didSet {
           updateProgress()
        }
     }
    
    private func updateProgress() {
        delegate?.downloadProgressUpdated(for: progress)
    }

    init(uuid: UUID){
        self.uuid = uuid
    }
    
    public var historySorted: [BeaconHistoryDataPointLocal] {
        return history.sorted {
            $0.timestamp < $1.timestamp
        }
    }

}

extension Download {
    func getDownloadUUID() -> UUID {
        return uuid
    }
}
