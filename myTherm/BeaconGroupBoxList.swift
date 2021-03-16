//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI

struct BeaconGroupBoxList: View {
    
    var fetchRequest: FetchRequest<Beacon>
    init(predicate: NSPredicate?) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                            predicate: predicate,
                                            animation: .default)
    }
    
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in     // PROFILE
            self.nowDate = Date()
        }
    }
    
    @State private var displaySteps: Int = 0    // 0 temp, 1 hum, 2 map
    
    var body: some View {
        VStack {
            ForEach(fetchRequest.wrappedValue, id: \.self) { beacon in
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
                                .frame(width: 25)
                            
                            Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)
                        }
                    , content: {
                        
                        VStack {
                            VStack {
                                if beacon.adv != nil {
                                    HStack {
                                        BeaconValueView(beacon: beacon, nowDate: nowDate)
                                            .frame(width: 165)
                                        Spacer()
                                        Button(action: {
                                            displaySteps = (displaySteps + 1) % 2
                                        }) {
                                            BeaconLineView(beacon: beacon, displaySteps: displaySteps)
//                                            Rectangle().border(Color.red)
                                        }
                                    }.frame(height: 55)
                                }
                            }
                            VStack {
                                BeaconDownloadView(
                                    beacon: beacon,
                                    activeDownloads: MyBluetoothManager.shared.downloadManager.activeDownloads)
                            }
                        }
                    }
                )
                .cornerRadius(10)
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}
//            .background(Color(.systemGroupedBackground))
//            .onAppear(perform: {
//                _ = self.timer
//            })
//            Spacer()
//                .frame(height: 50)
//                                        destination: BeaconDetail(beacon: beacon), beacon: beacon
//        }
//
//    }

