//
//  Download.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation

protocol DownloadDelegate: AnyObject {
    func downloadProgressUpdated(for progress: Float, for uuid: UUID)
}

enum DownloadStatus {
    case waiting, connecting, downloading_num, downloading_data, downloading_finished, alldone, cancelled, error
}

class Download : ObservableObject {

    weak var delegate: DownloadDelegate?
    
    var uuid: UUID
    var beacon: Beacon?
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
        if delegate != nil {
        delegate?.downloadProgressUpdated(for: progress, for: uuid)
        } else {
            print("updateProgress() delegate is nil")
        }
    }

    init(uuid: UUID, beacon: Beacon, delegate: DownloadDelegate ){
        self.uuid = uuid
        self.beacon = beacon
        self.delegate = delegate
    }
    
    deinit {
        if let beacon = beacon {
            beacon.localDownloadProgress = 0
        }
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
