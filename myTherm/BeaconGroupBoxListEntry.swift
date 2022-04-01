//
//  BeaconGroupBoxListEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 16.03.21.
//

import SwiftUI

struct BeaconGroupBoxListEntry: View {
    
    @ObservedObject var beacon: Beacon
    @ObservedObject var beaconAdv: BeaconAdv
    var nowDate: Date
    
    @StateObject var beaconModel = BeaconModel.shared
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
                        // hitches
                        NavigationLink(destination: BeaconDetail(beacon: beacon)//.environmentObject(lm)
                                       , tag: "Detail",
                                       selection: $selection) {
//                            EmptyView()
                        }
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
                        // BATTERY
                        if let adv = beacon.adv {
                            let batteryLevel = batteryLeveInPercent(mvolts: Int(adv.battery))
                            if batteryLevel < 20 {
                                HStack {
                                    Image(systemName: "battery.0").foregroundColor(.red).imageScale(.small)
                                }
                            } else if batteryLevel < 40 {
                                HStack {
                                    Image(systemName: "battery.25").foregroundColor(.yellow).imageScale(.small)
                                }
                            } else {
                                HStack {
//                                    Image(systemName: "battery.100").foregroundColor(.gray).imageScale(.small)
                                }
                            }
                        }
                            
                        // hitches
                        BeaconDownloadImageButton(
                            uuid: beacon.uuid!,
                            status: beacon.localDownloadStatus,
                            progress: beacon.localDownloadProgress,
                            timestamp: beacon.wrappedLocalTimestamp,
                            nowDate: nowDate)

                    }
                },
            content: {
                HStack {
                    VStack {
                        if localValue.isDragging {
                            BeaconValueView(temperature: localValue.temperature,
                                            humidity: localValue.humidity,
                                            string: localValue.timestamp != nil ? getDateString(date: localValue.timestamp!, offsetGMT: 0) : "no date")
                        } else {
                            BeaconValueView(temperature: beaconAdv.temperature,
                                            humidity: beaconAdv.humidity,
                                            string: beacon.wrappedAdvDateInterpretation(nowDate: nowDate))
                        }
                    }.frame(width: 165)
                    Spacer()
                                        BeaconLineView(beacon: beacon, localValue: localValue)
                    ////                                    DebugView5(beacon: beacon, localValue: localValue)
                    //                                }.frame(height: 55)
                }
                }
//            }
        )
    }
}

//struct BeaconGroupBoxListEntry_Previews_Container : View {
//    var beacon: Beacon = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Beacon }) as! Beacon
//    
//    @State var displaySteps: Int = 0
//    var body: some View {
//        BeaconGroupBoxListEntry(beacon: beacon, nowDate: Date(), displaySteps: $displaySteps)
//    }
//}
//
//
//struct BeaconGroupBoxListEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            BeaconGroupBoxListEntry_Previews_Container()
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//    }
//}
