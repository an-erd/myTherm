//
//  BeaconDownloadView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 11.03.21.
//

import SwiftUI

struct BeaconDownloadView: View {
    @ObservedObject var beacon: Beacon
    @State var activeDownloads: [Download]

    func getDownload(beacon: Beacon) -> Download? {
        let activeDownloadsFiltered =
            MyBluetoothManager.shared.downloadManager.activeDownloads.filter() { download in
            return download.uuid == beacon.uuid
        }
        return activeDownloadsFiltered.first
    }

    var body: some View {
        if let download = getDownload(beacon: beacon) {
//            GeometryReader { geometry in
            VStack (alignment: .leading) {
                HStack {
                    switch download.status {
                    case .waiting:
                        Text("Waiting...")
                        Spacer()
                    case .connecting:
                        ProgressView()
                        Text("Connecting...")
                        Spacer()
                    case .downloading_num, .downloading_data:
                        ProgressView(value: beacon.localDownloadProgress, total: 1.0)
                    case .downloading_finished:
                        Text("Done")
                        Spacer()
                    default:
                        Text("unknown")
                        Spacer()
                    }
                }
                .font(.footnote)
            }
            //                    .frame(width: geometry.size.width * 0.5)
//            }
        } else {
//            EmptyView()
            Text("no download for \(beacon.wrappedDeviceName)")
        }
    }
}

//struct BeaconDownloadView_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconDownloadView()
//    }
//}
