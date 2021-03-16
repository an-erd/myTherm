//
//  BeaconDownloadView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 11.03.21.
//

import SwiftUI

struct BeaconDownloadView: View {
    @ObservedObject var beacon: Beacon
    var activeDownloads: [Download]
    
    func getDownload(beacon: Beacon) -> Download? {
        let activeDownloadsFiltered = activeDownloads.filter() { download in
            return download.uuid == beacon.uuid
        }
        return activeDownloadsFiltered.first
    }
    
    var body: some View {
        if let download = getDownload(beacon: beacon) {
            VStack (alignment: .leading) {
                HStack {
                    switch download.status {
                    case .waiting:
                        Text("Waiting for Download...")
                        Spacer()
                    case .connecting:
                        ProgressView()
                            .padding(.trailing, 2)
                        Text("Connecting...")
                        Spacer()
                    case .downloading_num, .downloading_data:
                        Text("Downloading...")
                        Spacer()
                    case .downloading_finished:
                        Text("Donwload Done")
                        Spacer()
                    default:
                        Text("unknown")
                        Spacer()
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                HStack {
                    if ( download.status == .downloading_num ) || ( download.status == .downloading_data )  {
                        ProgressView(value: beacon.localDownloadProgress, total: 1.0)
                    }
                }
            }
        } else {
            AnyView(EmptyView())
        }
    }
}
