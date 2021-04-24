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
    @State private var selection: String? = nil

    func getDownload(beacon: Beacon) -> Download? {
        let activeDownloadsFiltered = MyCentralManagerDelegate.shared.downloadManager.downloads.filter() { download in
            return download.uuid == beacon.uuid
        }
        return activeDownloadsFiltered.first
    }
    
    var body: some View {
        GroupBox(
            label:
                HStack {
                    Group {
                        NavigationLink(destination: BeaconDetail(beacon: beacon).environmentObject(lm), tag: "Detail",
                                       selection: $selection) { EmptyView() }
                        Label(beacon.wrappedName, systemImage: "thermometer").foregroundColor(Color.blue)
                            .padding(.vertical, 5)
                            .padding(.trailing, 5)
                            //                                .border(Color.red)
                            .onTapGesture {
                                selection = "Detail"
                            }
                        Spacer()
                        if beacon.flag {
                            HStack {
                                Image(systemName: "flag.fill").foregroundColor(.orange).imageScale(.small)
                                Spacer().frame(width: 10)
                            }
                        }
                        if beacon.hidden {
                            HStack {
                                Image(systemName: "eye.slash").foregroundColor(.gray).imageScale(.small)
//                                Spacer().frame(width: 10)
                            }
                        }
                        BeaconDownloadImageButton(beacon: beacon,
                                                  activeDownload: getDownload(beacon: beacon),
                                                  nowDate: nowDate)
//                        Spacer().frame(width: 10)
//                        NavigationLink(destination: BeaconDetail(beacon: beacon).environmentObject(lm)) {
//                            Image(systemName: "chevron.right").foregroundColor(.secondary) //.imageScale(.small)
//                        }
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
//                                    Text("dist \(beacon.localDistanceFromPosition)")
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
