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
    @StateObject var beaconModel = BeaconModel.shared   // TODO
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
        animation: .default)
    private var beacons: FetchedResults<Beacon>
    
    @State private var editMode: EditMode = .inactive
    
    @State private var doScan: Bool = false
    @State private var doUpdateAdv: Bool = false
    
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
        let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons(context: viewContext)
        for beacon in beacons.sorted(by: { $0.wrappedDeviceName < $1.wrappedDeviceName }) {
            print("\(beacon.wrappedDeviceName) historyCount \(beacon.wrappedLocalHistoryTemperature.count) overallCount \(beacon.historyCount) distance \(beacon.localDistanceFromPosition)")
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
                HStack {
                    Toggle("Scan", isOn: $doScan)
                        .onChange(of: doScan, perform: { value in
                            if value == true {
                                MyCentralManagerDelegate.shared.startScanAndLocationService()
                            } else {
                                MyCentralManagerDelegate.shared.stopScanAndLocationService()
                            }
                            print("toggle update adv \(value)")
                        })
                    Spacer()
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
                        MyBluetoothManager.shared.downloadManager.addAllBeaconsToDownloadQueue()
                    }) {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    
                }
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
                //                copyStoreToLocalBeacons()
                copyBeaconHistoryOnce()
            }
        })
        .onDisappear(perform: {
            self.onDisappear()
//            DispatchQueue.main.async {
//                copyLocalBeaconsToStore()
//            }
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
                    DispatchQueue.main.async {
                        print("Tortoise start -------")
                        listBeaconChanges()
                        copyLocalBeaconsToWriteContext()
                        PersistenceController.shared.writeContext.performAndWait {
                            PersistenceController.shared.saveContext(context: PersistenceController.shared.writeContext)
                        }
                        listBeaconChanges()
                        print("Tortoise end -------")
                    }
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
    
    public func onDisappear() {
        print("onDisappear")
    }
    
    //    public func copyStoreToLocalBeacons() {
    //        print("copyStoreToLocalBeacons")
    //        let moc = PersistenceController.shared.container.viewContext
    //        moc.perform {
    //            for beacon in beacons {
    //                if let adv = beacon.adv {
    //                    if beacon.adv != nil { } else {
    //                        beacon.adv = BeaconAdv(context: moc)
    //                    }
    //                    if let localAdv = beacon.adv {
    //                        localAdv.copyContent(from: adv)
    //                    }
    //                }
    //
    //                if let location = beacon.location {
    //                    if beacon.location != nil { } else {
    //                        beacon.localLocation = BeaconLocation(context: moc)
    //                    }
    //                    if let localLocation = beacon.localLocation {
    //                        localLocation.copyContent(from: location)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    public func copyLocalBeaconsToWriteContext() {
        print("copyLocalBeaconsToStore")
        print("\(Thread.current)")  // must be on main!
        
        let viewMoc = PersistenceController.shared.viewContext
        let writeMoc = PersistenceController.shared.writeContext
        
        var toBeacon: Beacon!
        
        viewMoc.performAndWait {
            let fromBeacons = MyCentralManagerDelegate.shared.fetchAllBeacons(context: viewMoc)
            for fromBeacon in fromBeacons {
                writeMoc.performAndWait {
                    toBeacon = MyCentralManagerDelegate.shared.fetchBeacon(context: writeMoc, with: fromBeacon.uuid!)
                }
                if fromBeacon.changedValues().count > 0 {
                    print("copy     \(fromBeacon.wrappedDeviceName)")
                    let changes = fromBeacon.changedValues()
                    writeMoc.performAndWait {
                        if let toBeacon = toBeacon {
                            toBeacon.setValuesForKeys(changes)
                        } else {
                            print("toBeacon not found")
                        }
                    }
                }
                if let fromAdv = fromBeacon.adv {
                    if fromAdv.changedValues().count > 0 {
                        print("copy adv \(fromBeacon.wrappedDeviceName)")
                        let changes = fromAdv.changedValues()
                        writeMoc.performAndWait {
                            if toBeacon.adv != nil { } else {
                                toBeacon.adv = BeaconAdv(context: writeMoc)
                            }
                            if let toAdv = toBeacon.adv {
                                print("writeMoc changes \(toBeacon.wrappedDeviceName) > \(toAdv.changedValues().count)")
                                toAdv.setValuesForKeys(changes)
                                print("writeMoc changes \(toBeacon.wrappedDeviceName) < \(toAdv.changedValues().count)")
                            }
                        }
                    }
                }
                if let fromLocation = fromBeacon.location {
                    if fromLocation.changedValues().count > 0 {
                        print("copy loc \(fromBeacon.wrappedDeviceName)")
                        let changes = fromLocation.changedValues()
                        writeMoc.performAndWait {
                            if toBeacon.location != nil { } else {
                                toBeacon.location = BeaconLocation(context: writeMoc)
                            }
                            if let toLocation = toBeacon.location {
                                toLocation.setValuesForKeys(changes)
                            }
                        }
                    }
                }
            }
        }
    }

    public func copyBeaconHistoryOnce() {
        print("copyBeaconHistoryOnce")
        for beacon in beacons {
            //            print("copyBeaconHistoryOnce \(beacon.wrappedName)")
            beacon.copyHistoryArrayToLocalArray()
        }
    }
    
    public func listBeaconChanges() {
        print("listBeaconChanges")
        for beacon in beacons {
            var changes = beacon.changedValues()
            print("\(beacon.wrappedDeviceName) has \(changes.count) changes:")
            if changes.count > 0 { dump(changes) }
            
            if let adv = beacon.adv {
                changes = adv.changedValues()
                print("\(beacon.wrappedDeviceName) adv has \(changes.count) changes:")
                if changes.count > 0 { dump(changes) }
            }
            if let location = beacon.location {
                changes = location.changedValues()
                print("\(beacon.wrappedDeviceName) location has \(changes.count) changes:")
                if changes.count > 0 { dump(changes) }
            }
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
