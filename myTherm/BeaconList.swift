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
    @State private var doScan: Bool = false
    @State private var doUpdateAdv: Bool = false
    
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
                    HStack {
                        Toggle("Scan", isOn: $doScan)
                            .onChange(of: doScan, perform: { value in
                                if value == true {
                                    MyCentralManagerDelegate.shared.startScanAndLocationService()
                                } else {
                                    MyCentralManagerDelegate.shared.stopScanAndLocationService()
                                }
                                print("toggle scan \(value)")
                            })
                        Toggle("Adv", isOn: $doUpdateAdv)
                            .onChange(of: doUpdateAdv, perform: { value in
                                if value == true {
                                    MyCentralManagerDelegate.shared.startUpdateAdv()
                                } else {
                                    MyCentralManagerDelegate.shared.stopUpdateAdv()
                                }
                                print("toggle update adv \(value)")
                            })
                        Button(action: {
                            MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
                        }) {
                            Image(systemName: "icloud.and.arrow.down")
                            //                Image(systemName: "arrow.triangle.2.circlepath")
                            //                ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
                        }
                    }
                    ForEach(beacons) { beacon in
                        GroupBox(label: Label(beacon.wrappedName, systemImage: "thermometer")) {
                            if beacon.adv != nil {
                                VStack {
                                    HStack {
                                        BeaconValueView(beacon: beacon, nowDate: nowDate)
                                            .frame(width: geometry.size.width * 0.5)
                                        Spacer()
                                        Button(action: {
                                            displaySteps = (displaySteps + 1) % 2
                                        }) {
                                            BeaconLineView(beacon: beacon, displaySteps: displaySteps)
                                        }
                                    }
//                                    BeaconDownloadView(beacon: beacon) //, progress: beacon.localDownloadProgress)
                                }
                            }
                        }
                        .groupBoxStyle(
                            BeaconGroupBoxStyle(color: .blue,
                                                destination: BeaconDetail(beacon: beacon), beacon: beacon
                            ))
                    }
                    .padding()
                    Spacer()
                        .frame(height: 50)
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
