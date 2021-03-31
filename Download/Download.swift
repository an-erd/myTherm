//
//  Download.swift
//  myTherm
//
//  Created by Andreas Erdmann on 24.02.21.
//

import Foundation

protocol DownloadDelegate: AnyObject {
    func downloadProgressUpdated(for progress: Float, for uuid: UUID)
    func downloadStatusUpdated(for status: DownloadStatus, for uuid: UUID)
}

public enum DownloadStatus: Int32 {
    case waiting = 0
    case connecting = 1
    case downloading_num = 2
    case downloading_data = 3
    case downloading_finished = 4
    case alldone = 5
    case cancelled = 6
    case error = 7
    case none = 8
}

class Download : ObservableObject {

    weak var delegate: DownloadDelegate?
    
    var uuid: UUID
    var beacon: Beacon?
    var status: DownloadStatus = .waiting {
        didSet {
            updateStatus()
        }
    }

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

    private func updateStatus() {
        if delegate != nil {
        delegate?.downloadStatusUpdated(for: status, for: uuid)
        } else {
            print("updateStatus() delegate is nil")
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
