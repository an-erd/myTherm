//
//  BeaconDownloadViewEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 19.03.21.
//

import SwiftUI

struct BeaconDownloadViewEntry: View {
    
    @ObservedObject var beacon: Beacon
    @ObservedObject var download: Download
    
    var body: some View {
        
        VStack (alignment: .leading) {
            HStack {
                switch beacon.localDownloadStatus {
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
                if ( beacon.localDownloadStatus == .downloading_num ) ||
                    ( beacon.localDownloadStatus == .downloading_data )  {
                    ProgressView(value: beacon.localDownloadProgress, total: 1.0)
                }
            }
        }
    }
    
}

//struct BeaconDownloadViewEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconDownloadViewEntry()
//    }
//}
