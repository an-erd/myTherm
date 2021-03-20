//
//  BeaconGroupBoxListEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 16.03.21.
//

import SwiftUI

struct BeaconGroupBoxListEntry: View {
    
    @ObservedObject var beacon: Beacon
    var nowDate: Date
    @Binding var displaySteps: Int
    
    @StateObject var localValue: BeaconLocalValueView = BeaconLocalValueView()
    
    func getDownload(beacon: Beacon) -> Download? {
        let activeDownloadsFiltered = MyBluetoothManager.shared.downloadManager.activeDownloads.filter() { download in
            return download.uuid == beacon.uuid
        }
        return activeDownloadsFiltered.first
    }
    
    var body: some View {
        
        GroupBox(
            label:
                HStack {
                    Label(beacon.wrappedName, systemImage: "thermometer").foregroundColor(Color.blue)
                    Spacer()
                    Button(action: {
                        MyBluetoothManager.shared.downloadManager.addBeaconToDownloadQueue(beacon: beacon)
                    }) {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    Spacer()
                        .frame(width: 10)
                    
                    NavigationLink(destination: BeaconDetail(beacon: beacon)) {
                        Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)
                    }
                },
            content: {
                VStack {
                    VStack {
                        if beacon.adv != nil {
                            HStack {
                                BeaconValueView(beacon: beacon, localValue: localValue, nowDate: nowDate)
                                    .frame(width: 165)
                                Spacer()
                                Button(action: {
                                    displaySteps = (displaySteps + 1) % 2
                                }) {
                                    BeaconLineView(beacon: beacon, localValue: localValue, displaySteps: displaySteps)
                                }
                            }.frame(height: 55)
                        }
                    }
                    VStack {
                        BeaconDownloadView(
                            beacon: beacon,
                            activeDownload: getDownload(beacon: beacon))
                    }
                }
            }
        )
    }
}

//struct BeaconGroupBoxListEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconGroupBoxListEntry()
//    }
//}
