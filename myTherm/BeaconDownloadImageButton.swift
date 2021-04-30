//
//  BeaconDownloadImageButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 27.03.21.
//

import SwiftUI

struct BeaconDownloadImageButton: View {
    
    @ObservedObject var beacon: Beacon
    var activeDownload: Download?
    var nowDate: Date

    var body: some View {
        Button(action: {
            if activeDownload == nil {
                print("button addBeaconToDownloadQueue")
                MyCentralManagerDelegate.shared.downloadManager.addBeaconToDownloadQueue(uuid: beacon.uuid!)
            } else {
                switch beacon.localDownloadStatus {
                case .waiting, .connecting, .downloading_num, .downloading_data:
                    print("button .waiting, .connecting, .downloading_num, .downloading_data")
                    MyCentralManagerDelegate.shared.downloadManager.cancelDownloadForUuid(uuid: beacon.uuid!)
                case .alldone:
                    print("button .alldone")
                case .cancelled:
                    print("button .cancelled")
                case .error:
                    print("button .error")
                default:
                    print("button default")
                }
            }
        }) {
            ZStack {
                if activeDownload != nil {
                    switch beacon.localDownloadStatus {
                    case .waiting:
                        ProgressCircle(mode: .busy)
                    case .connecting:
                        ProgressCircle(progress: 0.0, mode: .progress)
                    case .downloading_num, .downloading_data:
                        ProgressCircle(progress: CGFloat(beacon.localDownloadProgress), mode: .progress)
                    case .downloading_finished:
                        Image(systemName: "checkmark")
                    case .alldone:
                        Image(systemName: "checkmark")
                    case .cancelled:
                        Image(systemName: "xmark")
                    case .error:
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                } else {
                    if let adv = beacon.adv, let timestamp = adv.timestamp {
                        if seenRecently(date: timestamp, nowDate: nowDate, timeInterval: 180) {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "icloud.and.arrow.down")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 24, height: 24)
//            .border(Color.red)
        }
    }
}




//struct BeaconDownloadImageButton_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconDownloadImageButton()
//    }
//}
