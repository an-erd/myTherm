//
//  BeaconDownloadView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 11.03.21.
//

import SwiftUI

struct BeaconDownloadView: View {
    
    @ObservedObject var beacon: Beacon
    var activeDownload: Download?
    //    @ObservedObject var activeDownloads: [Download]
    
    //    func getDownload(beacon: Beacon) -> Download? {
    //        let activeDownloadsFiltered = activeDownloads.filter() { download in
    //            return download.uuid == beacon.uuid
    //        }
    //        return activeDownloadsFiltered.first
    //    }
    
    var body: some View {
        if let activeDownload = activeDownload {
            BeaconDownloadViewEntry(beacon: beacon, download: activeDownload)
        } else {
            AnyView(EmptyView())
        }
    }
    
}
