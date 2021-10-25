//
//  BeaconDownloadImageButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 27.03.21.
//

import SwiftUI

struct BeaconDownloadImageButton: View, Equatable {
    
    var uuid: UUID
    var status: DownloadStatus
    var progress: Float
    var timestamp: Date
    var nowDate: Date

    var body: some View {
        Button(action: {
            switch status {
            case .waiting, .connecting, .downloading_num, .downloading_data:
                print("button .waiting, .connecting, .downloading_num, .downloading_data")
                MyCentralManagerDelegate.shared.downloadManager.cancelDownloadForUuid(uuid: uuid)
            case .downloading_finished:
                print("button .download_finished")
            case .alldone:
                print("button .alldone")
            case .cancelled:
                print("button .cancelled")
            case .error:
                print("button .error")
            case .none:
                print("button addBeaconToDownloadQueue")
                MyCentralManagerDelegate.shared.downloadManager.addBeaconToDownloadQueue(uuid: uuid)
            }
        }) {
            ZStack {
                switch status {
                case .waiting:
                    ProgressCircle(mode: .busy)
                case .connecting:
                    ProgressCircle(progress: 0.0, mode: .progress)
                case .downloading_num, .downloading_data:
                    ProgressCircle(progress: CGFloat(progress), mode: .progress)
                case .downloading_finished:
                    Image(systemName: "checkmark")
                case .alldone:
                    Image(systemName: "checkmark")
                case .cancelled:
                    Image(systemName: "xmark")
                case .error:
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                case .none:
                    if seenRecently(date: timestamp, nowDate: nowDate, timeInterval: 180) {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 24, height: 24)
//            .border(Color.red)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
//        return false
        
        if lhs.status != rhs.status {
            return false
        }
        
        switch lhs.status {
        case .connecting, .downloading_num, .downloading_data:
            return lhs.progress == rhs.progress
        case .none:
            return seenRecently(date: lhs.timestamp, nowDate: lhs.nowDate, timeInterval: 180)
                == seenRecently(date: rhs.timestamp, nowDate: rhs.nowDate, timeInterval: 180)
        default:
            return true
        }
    }
}


//struct BeaconDownloadImageButton_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconDownloadImageButton()
//    }
//}
