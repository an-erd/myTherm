//
//  BeaconList.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI
import CoreLocation
import OSLog

enum ActiveSheet: Identifiable {
    case filter, settings
    
    var id: Int {
        hashValue
    }
}

enum ActiveAlert: Identifiable {
    case downloadError
    
    var id: Int {
        hashValue
    }
}

struct BeaconList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var networkManager: NetworkManager
    @StateObject var beaconModel = BeaconModel.shared   // TODO
    @StateObject var downloadManager = DownloadManager.shared
    @StateObject var lm = LocationManager()
    @State var filteredListEntriesShown: Int = 0
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
        animation: .default)
    private var beacons: FetchedResults<Beacon>
    
    @State private var editMode: EditMode = .inactive
    
    @State private var doScan: Bool = false
    @State private var doUpdateAdv: Bool = false
    
    @State private var doFilter: Bool = false
    @State var activeSheet: ActiveSheet?
    @State var activeSheetDismiss: ActiveSheet?
    @State var predicateTimeFilter: NSPredicate?
    @State var predicateLocationFilter: NSPredicate?
    @State var predicateFlaggedFilter: NSPredicate?
    @State var predicateHiddenFilter: NSPredicate?
    @State var predicateShownFilter: NSPredicate?
    @State var compoundPredicate: NSCompoundPredicate?
    @State var filterPredicateUpdateTimer: Timer?
    let filterPredicateTimeinterval: Double = 180
    let filterPredicateDistanceMeter: Double = 500
    
    @State private var doErrorMessageDownload: Bool = false
    @State var activeAlert: ActiveAlert?
    
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
        withAnimation {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:
                                                        [NSPredicate(format: "hidden == NO or hidden == nil")])
        }
    }
    
    func filterUpdatePredicate() {
        var compound: [NSPredicate] = []
        
        if userSettings.filterByTime {
            let comparison = Date(timeIntervalSinceNow: -filterPredicateTimeinterval)
            predicateTimeFilter = NSPredicate(format: "localTimestamp >= %@", comparison as NSDate)
            if let predicateTimeFilter = predicateTimeFilter {
                compound.append(predicateTimeFilter)
            }
        }
        
        if userSettings.filterByLocation {
            predicateLocationFilter = NSPredicate(format: "localDistanceFromPosition <= %@", filterPredicateDistanceMeter as NSNumber)
            if let predicateLocationFilter = predicateLocationFilter {
                compound.append(predicateLocationFilter)
            }
        }
        
        if userSettings.filterByFlag {
            predicateFlaggedFilter = NSPredicate(format: "flag == true")
            if let predicateFlaggedFilter = predicateFlaggedFilter {
                compound.append(predicateFlaggedFilter)
            }
            
        }
        if userSettings.filterByHidden {
            predicateHiddenFilter = NSPredicate(format: "hidden == true")
            if let predicateHiddenFilter = predicateHiddenFilter {
                compound.append(predicateHiddenFilter)
            }
        }
        if userSettings.filterByShown {
            predicateShownFilter = NSPredicate(format: "hidden == false")
            if let predicateShownFilter = predicateShownFilter {
                compound.append(predicateShownFilter)
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
    
    fileprivate func buildViewBluetoothAutorization() -> some View {
        return BeaconListAlertEntry(title: "Bluetooth permission required",
                                    image: "exclamationmark.triangle.fill",
                                    text: "Sensors communicate by Bluetooth. On your phone, please go to Settings > Thermometer and turn on Bluetooth.",
                                    foregroundColor: .white,
                                    backgroundColor: Color("alertRed"),
                                    allowDismiss: false,
                                    dismiss: .constant(false))
    }
    
    fileprivate func buildViewLocationServices() -> some View {
        return BeaconListAlertEntry(title: "Location permission preferable",
                                    image: "questionmark.circle.fill",
                                    text: "To store sensor location, please allow location services. On your phone, please go to Settings > Thermometer and turn on Location services.",
                                    foregroundColor: .white,
                                    backgroundColor: Color("alertYellow"),
                                    allowDismiss: true,
                                    dismiss: $userSettings.showRequestLocationAlert)
    }
    
    fileprivate func buildViewInternet() -> some View {
        return BeaconListAlertEntry(title: "Internet connection preferable",
                                    image: "questionmark.circle.fill",
                                    text: "To upload your data to iCloud, please provide internet access.",
                                    foregroundColor: .white,
                                    backgroundColor: Color("alertYellow"),
                                    allowDismiss: true,
                                    dismiss: $userSettings.showRequestInternetAlert)
    }
    
    fileprivate func buildViewDebugTogglesScanAdv() -> some View {
        return VStack {
            Toggle("Scan", isOn: $doScan)
                .onChange(of: doScan, perform: { value in
                    if value == true {
                        MyCentralManagerDelegate.shared.startScanAndLocationService()
                    } else {
                        MyCentralManagerDelegate.shared.stopScanAndLocationService()
                    }
                    print("toggle update adv \(value)")
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
        }
        .padding()
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 8) {
                
                if !beaconModel.isBluetoothAuthorization {
                    buildViewBluetoothAutorization()
                }
                
                if (userSettings.showRequestLocationAlert) {
                    if (lm.status == .restricted) || (lm.status == .denied) {
                        buildViewLocationServices()
                    }
                }
                if (!networkManager.isConnected) {
                    buildViewInternet()
                }
#if DEBUG_ADV
                buildViewDebugTogglesScanAdv()
#endif
                //                    Button(action: {
                //                        MyBluetoothManager.shared.downloadManager.addAllBeaconsToDownloadQueue()
                //                    }) {
                //                        Image(systemName: "icloud.and.arrow.down")
                //                    }
            }
            withAnimation {
                BeaconGroupBoxList(predicate: compoundPredicate)
                    .environmentObject(lm)
            }
            //                BeaconBottomBarStatusFilterButton(filterActive: doFilter, filterByTime: $filterByTime, filterByLocation: $filterByLocation, filterByFlag: $filterByFlag)
            //            }
        }
        
        .onAppear(perform: {
            self.onAppear()
            stopFilterUpdate()
            
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
                }
                
                Spacer()
                ZStack {
                    BeaconBottomBarStatusFilterButton(
                        filterActive: doFilter,
                        filterByTime: $userSettings.filterByTime,
                        filterByLocation: $userSettings.filterByLocation,
                        filterByFlag: $userSettings.filterByFlag,
                        filterByHidden: $userSettings.filterByHidden,
                        predicate: compoundPredicate)
                        .opacity(!(beaconModel.isDownloadStatusError
                                    || beaconModel.isDownloading
                                    || beaconModel.isDownloadStatusSuccess) ? 1 : 0)
                    
                    BeaconBottomBarStatusDownloadButton(
                        textLine1: beaconModel.textDownloadStatusErrorLine1, colorLine1: .primary,
                        textLine2: beaconModel.textDownloadStatusErrorLine2, colorLine2: .blue)
                        .opacity(beaconModel.isDownloadStatusError ? 1 : 0)
                    
                    BeaconBottomBarStatusDownloadButton(
                        textLine1: beaconModel.textDownloadingStatusLine1, colorLine1: .primary,
                        textLine2: beaconModel.textDownloadingStatusLine2, colorLine2: .primary)
                        .opacity(beaconModel.isDownloadStatusSuccess ? 1 : 0)
                    
                    Button(action: {
                        if beaconModel.isDownloadStatusError {
                            activeAlert = .downloadError
                        } else if doFilter {
                            activeSheet = .filter
                        }
                    }) {
                        HStack { }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                Spacer()

//                Button(action: { }
//                ) {
//                    Image(systemName: "tortoise")
//                }
            }
        }
        .navigationBarItems(
            leading:
                HStack {
                    Button(action: {
                        activeSheet = .settings
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    .foregroundColor(.primary)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 2)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
                },
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
                        HStack {
                            if doScan {
                                Text("Stop Update")
                            } else {
                                Text("Update")
                            }
                        }
                        .frame(width: 100, alignment: .trailing)
                    }
                    
//                    Button("•••") {
//                        activeSheet = .settings
//                    }
//                    .foregroundColor(Color.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 2)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
                }
        )
        .sheet(item: $activeSheet) { item in
            switch item {
            case .filter:
                BeaconFilterSettingsSheet(filterByTime: $userSettings.filterByTime,
                                          filterByLocation: $userSettings.filterByLocation,
                                          filterByFlag: $userSettings.filterByFlag,
                                          filterByHidden: $userSettings.filterByHidden,
                                          filterByShown: $userSettings.filterByShown)
                    .environmentObject(beaconModel)
            case .settings:
                BeaconConfigSettingsSheet()
            }
        }
        .alert(item: $activeAlert) { item in
            switch item {
            case .downloadError:
                return Alert(
                    title: Text("Download errors"),
                    message: Text("Download sensor data is complete. Retrieval did not succeed for the following sensors:\n\(downloadManager.buildDownloadErrorDeviceList())"),
                    dismissButton: .default(Text("OK"),
                                            action: { downloadManager.clearDownloadErrorAndResume() })
                )
            }
        }
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
    

    public func resetDistanceBeaconOnce() {
        print("resetDistanceBeaconOnce")
        for beacon in beacons {
            beacon.localDistanceFromPosition = -1
        }
    }
    
    public func listBeaconChanges() {
        var changesBeacon: [String : Any ] = [:]
        var changesBeaconAdv: [ String : Any ] = [:]
        var changesBeaconLocation: [ String : Any ] = [:]
        
        print("listBeaconChanges")
        for beacon in beacons {
            changesBeacon = beacon.changedValues()
            if let adv = beacon.adv {
                changesBeaconAdv = adv.changedValues()
            }
            if let location = beacon.location {
                changesBeaconLocation = location.changedValues()
            }
            print("\(beacon.wrappedDeviceName) Changes: Beacon \(changesBeacon.count), adv \(changesBeaconAdv.count), location \(changesBeaconLocation.count) Distance \(beacon.localDistanceFromPosition)")
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
