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
    @State private var doScan: Bool = true
    @State private var doUpdateAdv: Bool = true
    
    @State private var doFilter: Bool = false
    @State var predicate: NSPredicate?
    @State var filterPredicateUpdateTimer: Timer?
    @State var filterCriteria: Int = 0
    let filterPredicateTimeinterval: Double = 30
    
    func startFilterUpdate() {
        filterUpdatePredicate()
        filterPredicateUpdateTimer =
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                filterUpdatePredicate()
            }
    }
    
    func stopFilterUpdate() {
        if let timer = filterPredicateUpdateTimer {
            timer.invalidate()
        }
        predicate = nil
    }
    
    func filterUpdatePredicate() {
        withAnimation {
            let comparison = Date(timeIntervalSinceNow: -filterPredicateTimeinterval)
            predicate = NSPredicate(format: "localTimestamp >= %@", comparison as NSDate)
        }
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    //                        Toggle("Scan", isOn: $doScan)
                    //                            .onChange(of: doScan, perform: { value in
                    //                                if value == true {
                    //                                    MyCentralManagerDelegate.shared.startScanAndLocationService()
                    //                                } else {
                    //                                    MyCentralManagerDelegate.shared.stopScanAndLocationService()
                    //                                }
                    //                                print("toggle scan \(value)")
                    //                            })
                    //                        Toggle("Adv", isOn: $doUpdateAdv)
                    //                            .onChange(of: doUpdateAdv, perform: { value in
                    //                                if value == true {
                    //                                    MyCentralManagerDelegate.shared.startUpdateAdv()
                    //                                } else {
                    //                                    MyCentralManagerDelegate.shared.stopUpdateAdv()
                    //                                }
                    //                                print("toggle update adv \(value)")
                    //                            })
                    //                    Toggle("Filter", isOn: $doFilter)
                    //                        .onChange(of: doFilter, perform: { value in
                    //                            if value == true {
                    //                                startFilterUpdate()
                    //                            } else {
                    //                                stopFilterUpdate()
                    //                            }
                    //                            print("toggle filter \(value)")
                    //                        })
                    //                        Button(action: {
                    //                            MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
                    //                        }) {
                    //                            Image(systemName: "icloud.and.arrow.down")
                    //                        }
                }
                withAnimation {
                    BeaconGroupBoxList(predicate: predicate)
                }
            }
        }
        .onAppear(perform: {
            self.onAppear()
            copyBeaconHistoryOnce()
        })
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    withAnimation {
                        print("Filter pressed")
                        doFilter.toggle()
                        if doFilter {
                            startFilterUpdate()
                        } else {
                            stopFilterUpdate()
                        }
                    }
                }
                ) {
                    HStack {
                        doFilter ? Image(systemName: "line.horizontal.3.decrease.circle.fill") :
                            Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
                Spacer()
                Text("status text")
                Spacer()
                Button("Second") {
                    print("Pressed")
                }
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                //                        MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
                if doScan {
                    doScan = false
                    MyCentralManagerDelegate.shared.stopScanAndLocationService()
                } else {
                    doScan = true
                    MyCentralManagerDelegate.shared.startScanAndLocationService()
                }
            }) {
                if doScan {
                    Text("Stop Scan")
                } else {
                    Text("Scan")
                }
            }
        )
        
        
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
