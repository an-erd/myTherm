//
//  BeaconGroupBoxListEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 16.03.21.
//

import SwiftUI

struct BeaconGroupBoxListEntry: View {
    
    @StateObject var model = BeaconModel.shared
    @EnvironmentObject var lm: LocationManager

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
                    Group {
                        Label(beacon.wrappedName, systemImage: "thermometer").foregroundColor(Color.blue)
                        Spacer()
                        HStack {
                            Image(systemName: "flag.fill").foregroundColor(.orange).imageScale(.small)
                            Spacer().frame(width: 10)
                        }
                        .isHidden(!beacon.flag)
                        BeaconDownloadImageButton(beacon: beacon, activeDownload: getDownload(beacon: beacon))
                        Spacer().frame(width: 10)
                        NavigationLink(destination: BeaconDetail(beacon: beacon).environmentObject(lm)) {
                            Image(systemName: "chevron.right").foregroundColor(.secondary) //.imageScale(.small)
                        }
                    }
                },
            content: {
                VStack {
                    VStack {
                        if beacon.adv != nil {
                            withAnimation {
                                HStack {
                                    BeaconValueView(beacon: beacon, localValue: localValue, nowDate: nowDate)
                                        .frame(width: 165)
                                    Spacer()
                                    BeaconLineView(beacon: beacon, localValue: localValue, displaySteps: displaySteps)
                                }.frame(height: 55)
                            }
                        }
                    }
                }
            }
        )
    }
}

struct BeaconGroupBoxListEntry_Previews_Container : View {
    var beacon: Beacon = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Beacon }) as! Beacon
    
    @State var displaySteps: Int = 0
    var body: some View {
        BeaconGroupBoxListEntry(beacon: beacon, nowDate: Date(), displaySteps: $displaySteps)
    }
}


struct BeaconGroupBoxListEntry_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BeaconGroupBoxListEntry_Previews_Container()
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
