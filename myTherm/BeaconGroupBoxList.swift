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
                GroupBox(label: Label(beacon.wrappedName, systemImage: "thermometer")) {
                    if beacon.adv != nil {
                        VStack {
                            HStack {
                                BeaconValueView(beacon: beacon, nowDate: nowDate)
                                    .frame(width: 165)
                                Spacer()
                                Button(action: {
                                    displaySteps = (displaySteps + 1) % 2
                                }) {
                                    BeaconLineView(beacon: beacon, displaySteps: displaySteps)
                                }
                            }
                            BeaconDownloadView(
                                beacon: beacon,
                                activeDownloads: MyBluetoothManager.shared.downloadManager.activeDownloads)
                        }
                    }
                }
                .groupBoxStyle(
                    BeaconGroupBoxStyle(color: .blue,
                                        destination: BeaconDetail(beacon: beacon), beacon: beacon
                    ))
//                .border(Color.white)
            }
            .padding()
            Spacer()
                .frame(height: 50)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            _ = self.timer
        })
    }
    
}

