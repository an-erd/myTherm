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
    @State private var doScan: Bool = false
    @State private var doUpdateAdv: Bool = false
    @State private var doFilter: Bool = false
    
    @State var predicate: NSPredicate?
    
    var body: some View {
        
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
                        Toggle("Filter", isOn: $doFilter)
                            .onChange(of: doFilter, perform: { value in
                                if value == true {
                                    let comparison = Date(timeIntervalSinceNow: -120)
                                    predicate = NSPredicate(format: "localTimestamp >= %@", comparison as NSDate)
                                } else {
                                    predicate = nil
                                }
                                print("toggle filter \(value)")
                            })
//                        Button(action: {
//                            MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
//                        }) {
//                            Image(systemName: "icloud.and.arrow.down")
//                        }
                    }
                    BeaconGroupBoxList(predicate: predicate)
                }
            }
            .onAppear(perform: {
                self.onAppear()
                copyBeaconHistoryOnce()
            })
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        print("Filter pressed")
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                    Spacer()
                    Text("status text")
                    Spacer()
                    Button("Second") {
                        print("Pressed")
                    }
                }
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
