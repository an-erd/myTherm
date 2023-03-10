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
                    ProgressCircle(progress: CGFloat(beacon.localDownloadProgress), mode: .idle)
                    Text("Waiting for Download...")
                    Spacer()
                case .connecting:
                    ProgressView()
                        .padding(.trailing, 2)
                    ProgressCircle(progress: CGFloat(beacon.localDownloadProgress), mode: .busy)

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
                    ProgressView(value: Float(beacon.localDownloadProgress), total: 1.0)
                    ProgressCircle(progress: CGFloat(beacon.localDownloadProgress), mode: .progress)
                }
            }
        }
    }
    
}

struct BeaconDownloadViewEntry_Previews_Container : View {
    var beacon: Beacon = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Beacon }) as! Beacon
    
    var body: some View {
        BeaconDownloadViewEntry(beacon: beacon, download: Download(uuid: beacon.uuid!, beacon: beacon)) //, delegate: beacon))
     }
    
}

struct BeaconDownloadViewEntry_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BeaconDownloadViewEntry_Previews_Container()
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
