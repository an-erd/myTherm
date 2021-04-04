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
    @EnvironmentObject var lm: LocationManager

    //    @EnvironmentObject var beaconModel: BeaconModel
    @StateObject var beaconModel = BeaconModel.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
        animation: .default)
    private var beacons: FetchedResults<Beacon>
    
    @State private var editMode: EditMode = .inactive
    
    @State private var doScan: Bool = true
    @State private var doUpdateAdv: Bool = true
    
    @State private var doFilter: Bool = false
    @State var predicateTimeFilter: NSPredicate?
    @State var predicateLocationFilter: NSPredicate?
    @State var predicateFlaggedFilter: NSPredicate?
    @State var compoundPredicate: NSCompoundPredicate?
    @State var filterPredicateUpdateTimer: Timer?
    @State var filterByTime: Bool = true
    @State var filterByLocation: Bool = false
    @State var filterByFlag: Bool = false
    let filterPredicateTimeinterval: Double = 30
    let filterPredicateDistanceMeter: Double = 50
    
    @State var sort: Int = 0
    
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
        predicateTimeFilter = nil
        predicateLocationFilter = nil
        predicateFlaggedFilter = nil
        compoundPredicate = nil
    }
    
    func filterUpdatePredicate() {
        var compound: [NSPredicate] = []
        
        if filterByTime {
            let comparison = Date(timeIntervalSinceNow: -filterPredicateTimeinterval)
            predicateTimeFilter = NSPredicate(format: "localTimestamp >= %@", comparison as NSDate)
            if let predicateTimeFilter = predicateTimeFilter {
                compound.append(predicateTimeFilter)
            }
        }
        
        if filterByLocation {
            predicateLocationFilter = NSPredicate(format: "localDistanceFromPosition <= %@", filterPredicateDistanceMeter as NSNumber)
            if let predicateLocationFilter = predicateLocationFilter {
                compound.append(predicateLocationFilter)
            }
        }
        
        if filterByFlag {
            predicateFlaggedFilter = NSPredicate(format: "flag == true")
            if let predicateFlaggedFilter = predicateFlaggedFilter {
                compound.append(predicateFlaggedFilter)
            }

        }
        withAnimation {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: compound)
        }
    }
    
    func printBeaconListHistoryCount() {
        let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons()
        for beacon in beacons {
            print("\(beacon.wrappedDeviceName) historyCount \(beacon.wrappedLocalHistoryTemperature.count) distance \(beacon.localDistanceFromPosition)")
        }
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 8) {
                
                if !beaconModel.isBluetoothAuthorization {
                    BeaconListAlertEntry(title: "Bluetooth permission required",
                                         image: "exclamationmark.triangle.fill",
                                         text: "Sensors communicate by Bluetooth. On your phone, please go to Settings > Thermometer and turn on Bluetooth.",
                                         foregroundColor: .white,
                                         backgroundColor: Color("alertRed"))
                }
                
                if (lm.status == .restricted) || (lm.status == .denied) {
                    BeaconListAlertEntry(title: "Location permission preferable",
                                         image: "questionmark.circle.fill",
                                         text: "If you want to store sensor location, you should allow location services. On your phone, please go to Settings > Thermometer and turn on Location services.",
                                         foregroundColor: .white,
                                         backgroundColor: Color("alertYellow"))
                }
//                
//                BeaconListAlertEntry(title: "No data yet",
//                                     image: "questionmark.circle.fill",
//                                     text: "Sensors available? Placed too far away?",
//                                     foregroundColor: .white,
//                                     backgroundColor: Color("alertGreen"))
//                BeaconListAlertEntry(title: "No data yet 2",
//                                     image: "questionmark.circle.fill",
//                                     text: "Sensors available? Placed too far away?",
//                                     foregroundColor: .white,
//                                     backgroundColor: Color("alertBlue"))
//                
                //                    Toggle("Adv", isOn: $doUpdateAdv)
                //                        .onChange(of: doUpdateAdv, perform: { value in
                //                            if value == true {
                //                                MyCentralManagerDelegate.shared.startUpdateAdv()
                //                            } else {
                //                                MyCentralManagerDelegate.shared.stopUpdateAdv()
                //                            }
                //                            print("toggle update adv \(value)")
                //                        })
                //                    Button(action: {
                //                        MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
                //                    }) {
                //                        Image(systemName: "icloud.and.arrow.down")
                //                    }
            }
            withAnimation {
                BeaconGroupBoxList(predicate: compoundPredicate)
            }
            //                BeaconBottomBarStatusFilterButton(filterActive: doFilter, filterByTime: $filterByTime, filterByLocation: $filterByLocation, filterByFlag: $filterByFlag)
            //            }
        }
        .onAppear(perform: {
            self.onAppear()
            DispatchQueue.main.async {
                copyBeaconHistoryOnce()
            }
        })
        .toolbar {
            ToolbarItemGroup (placement: .bottomBar) {
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
                        if doFilter {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .font(.largeTitle)
                        } else {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                    }
                    .padding()
                    //                    .border(Color.white)
                }
                
                Spacer()
                ZStack {
                    BeaconBottomBarStatusFilterButton(
                        filterActive: doFilter, filterString: "\(beacons.count) sensors found",
                        filterByTime: $filterByTime, filterByLocation: $filterByLocation, filterByFlag: $filterByFlag)
                    if doFilter {
                        Button(action: { beaconModel.isPresentingSettingsView.toggle() } ) {
                            HStack { }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            //                                .border(Color.white)
                        }
                    }
                }
                Spacer()
                Button(action: {
                    // show debug settings dialog
                        printBeaconListHistoryCount()
                }
                ) {
                    Image(systemName: "tortoise")
                }
            }
        }
        .navigationBarItems(
            trailing:
                HStack {
                    Spacer()
                    Button(action: {
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
                    .padding(10)
                    //                    .border(Color.white)
                }
        )
        .sheet(
            isPresented: $beaconModel.isPresentingSettingsView,
            onDismiss: { beaconModel.isPresentingSettingsView = false },
            content: {
                BeaconFilterSheet(filterByTime: $filterByTime,
                                  filterByLocation: $filterByLocation,
                                  filterByFlag: $filterByFlag)
                    .environmentObject(beaconModel)
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
            .environmentObject(BeaconModel())
            .environmentObject(ViewRouter())
    }
}
