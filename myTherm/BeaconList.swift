//
//  BeaconList.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI

struct BeaconList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
        animation: .default)
    private var beacons: FetchedResults<Beacon>
    
    @State private var editMode: EditMode = .inactive
    @State private var displaySteps: Int = 0    // 0 temp, 1 hum, 2 map
    @State private var doScan: Bool = true
    
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in     // PROFILE
            self.nowDate = Date()
        }
    }
    
    //    @State var data1: [Double] = (0..<100).map { _ in .random(in: 9.0...100.0) }
    //    let blueStyle = ChartStyle(backgroundColor: .white,
    //                               foregroundColor: [ColorGradient(.purple, .blue)])
    
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 8) {
                    Toggle("Scan", isOn: $doScan)
                        .onChange(of: doScan, perform: { value in
                            if value == true {
                                MyCentralManagerDelegate.shared.startScanAndLocationService()
                            } else {
                                MyCentralManagerDelegate.shared.stopScanAndLocationService()
                            }
                            print("toggle scan \(value)")
                        })
                    ForEach(beacons) { beacon in
                        GroupBox(label: Label(beacon.name!, systemImage: "thermometer")) {
                            VStack {
                                HStack {
                                    BeaconValueView(beacon: beacon, beaconAdv: beacon.adv!, nowDate: nowDate)
                                        .frame(width: geometry.size.width * 0.5)
                                    
                                    Button(action: {
                                        displaySteps = (displaySteps + 1) % 2
                                    }) {
                                        ZStack {// PROFILE
                                            if displaySteps == 0 {
                                                LineView(timestamp: beacon.localHistoryTimestamp ?? [] ,
                                                         data: beacon.localHistoryTemperature ?? [], title: "°C") // PROFIL
                                            } else if displaySteps == 1 {
                                                LineView(timestamp: beacon.localHistoryTimestamp ?? [],
                                                         data: beacon.localHistoryHumidity ?? [], title: "%")
                                            } else {
                                                Text("No data available")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                if (beacon.localDownloadProgress > 0) &&
                                    (beacon.localDownloadProgress < 1) {
                                    ProgressView(value: beacon.localDownloadProgress, total: 1.0)
                                }
                            }
                        }
                        .groupBoxStyle(
                            BeaconGroupBoxStyle(color: .blue,
                                                destination: BeaconDetail(beacon: beacon, beaconadv: beacon.adv!),
                                                dateString: getDateInterpretationString(date: beacon.adv!.timestamp!, nowDate: nowDate)))
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear(perform: {
                self.onAppear()
                _ = self.timer    // PROFIL
                copyBeaconHistoryOnce()
            })
        }
        
    }
    
    public func onAppear() {
        print("onAppear")
    }
    
    public func copyBeaconHistoryOnce() {
        for beacon in beacons {
            print("copyBeaconHistoryOnce \(beacon.wrappedName)")
            beacon.copyHistoryArrayToLocalArray()
        }
    }
}


struct BeaconList_Previews: PreviewProvider {
    static var previews: some View {
        BeaconList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
