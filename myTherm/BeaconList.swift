//
//  BeaconList.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation
import CoreData
import OSLog


struct BeaconList: View, Equatable {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var networkManager: NetworkManager
    @StateObject var beaconModel = BeaconModel.shared
    @StateObject var downloadManager = DownloadManager.shared
    @StateObject var lm = LocationManager.shared
    var authMode = LocationManager.shared.locationAuthorizationStatus

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var devices: FetchedResults<Devices>

    @State private var editMode: EditMode = .inactive
    @State private var doFilter: Bool = false
    @State var activeSheet: ActiveSheet?
    @State var activeSheetDismiss: ActiveSheet?
    @State var predicateTimeFilter: NSPredicate?
    @State var predicateLocationFilter: NSPredicate?
    @State var predicateFlaggedFilter: NSPredicate?
    @State var predicateHiddenFilter: NSPredicate?
    @State var predicateShownFilter: NSPredicate?
    @State var compoundPredicateWithFilter: NSCompoundPredicate?
    @State var compoundPredicateWithoutFilter: NSCompoundPredicate?
    @State var filterPredicateUpdateTimer: Timer?
    let filterPredicateTimeinterval: Double = 180
    let filterPredicateDistanceMeter: Double = 100
    
    @State var filter: Bool = false

    @State private var doErrorMessageDownload: Bool = false
//    @State var activeAlert: ActiveAlert?

    @State var sort: Int = 0
    
//    @State var isScrolling = false
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>

    init() {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
    }

    private let log: OSLog = OSLog(subsystem: "com.anerd.myTherm", category: "Useraction")

    func startFilterUpdate() {
        filterPredicateUpdateTimer =
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                filterWithFilterUpdatePredicate()
            }
    }

    func stopFilterUpdate() {
        if let timer = filterPredicateUpdateTimer {
            timer.invalidate()
        }
        os_signpost(.event, log: self.log, name: "Useraction", "pred_update")
    }

    func filterWithoutFilterInitPredicate() {
        compoundPredicateWithoutFilter = NSCompoundPredicate(andPredicateWithSubpredicates:
                                                                [NSPredicate(format: "hidden == NO or hidden == nil")])
    }
    
    func filterWithFilterUpdatePredicate() {
        var compound: [NSPredicate] = []

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
            predicateShownFilter = NSPredicate(format: "hidden != true")
            if let predicateShownFilter = predicateShownFilter {
                compound.append(predicateShownFilter)
            }
        }

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

        os_signpost(.event, log: self.log, name: "Useraction", "pred_update")
        withAnimation {
            compoundPredicateWithFilter = NSCompoundPredicate(andPredicateWithSubpredicates: compound)
        }
    }

    func printBeaconListHistoryCount() {
        let beacons: [Beacon] = beaconModel.fetchAllBeaconsFromStore(context: viewContext)
        for beacon in beacons.sorted(by: { $0.wrappedDeviceName < $1.wrappedDeviceName }) {
            print("\(beacon.wrappedDeviceName) historyCount \(beacon.wrappedLocalHistoryTemperature.count) overallCount \(beacon.historyCount) distance \(beacon.localDistanceFromPosition)")
        }
    }

    fileprivate func buildViewBluetoothAutorization() -> some View {
        if !beaconModel.isBluetoothAuthorization {
            return AnyView( BeaconListAlertEntry(title: "Bluetooth permission required",
                                        image: "exclamationmark.triangle.fill",
                                        text: "Sensors communicate by Bluetooth. On your phone, please go to Settings > Thermometer and turn on Bluetooth.",
                                        foregroundColor: .white,
                                        backgroundColor: Color("alertRed"),
                                        allowDismiss: false,
                                        dismiss: .constant(false))
                .equatable()
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    fileprivate func buildViewLocationServices() -> some View {
        if (lm.locationAuthorizationStatus == .restricted) || (lm.locationAuthorizationStatus == .denied) {
            return AnyView( BeaconListAlertEntry(title: "Location permission preferable",
                                    image: "questionmark.circle.fill",
                                    text: "To store sensor location, please allow precise location services. On your phone, please go to Settings > Thermometer and turn on Location services.",
                                    foregroundColor: .white,
                                    backgroundColor: Color("alertYellow"),
                                    allowDismiss: true,
                                    dismiss: $userSettings.showRequestLocationAlert)
            .equatable()
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    fileprivate func buildViewInternet() -> some View {
        if (!networkManager.isConnected) {
            return AnyView(BeaconListAlertEntry(title: "Internet connection preferable",
                                                image: "questionmark.circle.fill",
                                                text: "To upload your data to iCloud, please provide internet access.",
                                                foregroundColor: .white,
                                                backgroundColor: Color("alertYellow"),
                                                allowDismiss: true,
                                                dismiss: $userSettings.showRequestInternetAlert)
                            .equatable()
            )
        } else {
            return AnyView(EmptyView())
        }
        
    }

//    fileprivate func buildViewDebugTogglesScanAdv() -> some View {
//        return VStack {
//            Toggle("Scan", isOn: $beaconModel.doScan)
//                .onChange(of: beaconModel.doScan, perform: { value in
//                    if value == true {
//                        MyCentralManagerDelegate.shared.startScanService()
//                    } else {
//                        MyCentralManagerDelegate.shared.stopScanService()
//                    }
//                    print("toggle update adv \(value)")
//                })
//            Toggle("Adv", isOn: $beaconModel.doUpdateAdv)
//                .onChange(of: beaconModel.doUpdateAdv, perform: { value in
//                    if value == true {
//                        MyCentralManagerDelegate.shared.startUpdateAdv()
//                    } else {
//                        MyCentralManagerDelegate.shared.stopUpdateAdv()
//                    }
//                    print("toggle update adv \(value)")
//                })
//        }
//        .padding()
//    }

    var body: some View {
        
        //        VStack {
        //            ZStack {
        //            }
//        if beaconModel.isScrollUpdate {
//            Text("scrollupdate")
//        } else {
//            Text("no scrollupate")
//        }
        ScrollView {
            VStack {
                VStack(spacing: 8) {

                    //                    if !beaconModel.isBluetoothAuthorization {
                    buildViewBluetoothAutorization()
                    //                    }
                    
                    //                if (userSettings.showRequestLocationAlert) {
                    //                    if (lm.locationAuthorizationStatus == .restricted) || (lm.locationAuthorizationStatus == .denied) {
                    buildViewLocationServices()
                    //                    }
                    //                }
                    //                    if (!networkManager.isConnected) {
                    buildViewInternet()
                    //                    }
                    
                    //                    #if DEBUG_ADV
                    //                    buildViewDebugTogglesScanAdv()
                    //                    #endif
                    //                    Button(action: {
                    //                        MyBluetoothManager.shared.downloadManager.addAllBeaconsToDownloadQueue()
                    //                    }) {
                    //                        Image(systemName: "icloud.and.arrow.down")
                    //                    }
                    //                    if beaconModel.isScrollUpdate {
                    //                    HStack {
                    //                        Text("scroll update")
                    //                    }
                    //                    }
                }
                withAnimation {
                    BeaconGroupBoxList(doFilter: doFilter,
                                       predicateWithoutFilter: compoundPredicateWithoutFilter,
                                       predicateWithFilter: compoundPredicateWithFilter)
                }
                //                }
            }
            .background(GeometryReader {
                Color.clear.preference(key: ViewOffsetKey.self,
                                       value: -$0.frame(in: .named("scroll")).origin.y)
            })
            .onPreferenceChange(ViewOffsetKey.self) {val in
                DispatchQueue.main.async {
                    //                print("scroll position \($0)")
                    if !beaconModel.isScrolling {
                        beaconModel.isScrolling = true
                        //                    beaconModel.taskSemaphore.wait()
                        //                    print("start scroll")
                    }
                    if val < -100 {
                        if !beaconModel.isScrollUpdate {
                            beaconModel.isScrollUpdate = true
                            //                        print("scroll -> update start")
                            MyCentralManagerDelegate.shared.startScanService()
                        }
                    } else {
                        if beaconModel.isScrollUpdate {
                            beaconModel.isScrollUpdate = false
                            //                        print("scroll -> update stop")
                        }
                    }
                    detector.send(val)
                }
            }
            //            DebugTestView(beacons: devices.first!.beaconArray, filter: filter)
            //            DebugView1(predicate: compoundPredicate)
        }
        ////        .simultaneousGesture(
        //        .gesture(
        //            DragGesture()
        //                .onChanged { gesture in
        //                    print("Started Scrolling")
        //                    isScrolling = true
        //                }
        //        )
        .coordinateSpace(name: "scroll")
        .onReceive(publisher) {
            print("Stopped scroll on: \($0)")
            beaconModel.isScrolling = false
            //            beaconModel.taskSemaphore.signal()
        }
        .onAppear(perform: {
            self.onAppear()
            filterWithoutFilterInitPredicate()
            filterWithFilterUpdatePredicate()
            stopFilterUpdate()
            beaconModel.isScrolling = false
        })
        .onDisappear(perform: {
            self.onDisappear()
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
                        os_signpost(.event, log: self.log, name: "Useraction", "filter_%{public}s", doFilter ? "y" : "n")
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
                    //                    Text("filterbutton")
                    // hitches
                    BeaconBottomBarStatusFilterButton(
                        filterActive: doFilter,
                        filterByTime: $userSettings.filterByTime,
                        filterByLocation: $userSettings.filterByLocation,
                        filterByFlag: $userSettings.filterByFlag,
                        filterByHidden: $userSettings.filterByHidden,
                        filterByShown: $userSettings.filterByShown,
                        compoundPredicateWithFilter: compoundPredicateWithFilter,
                        compoundPredicateWithoutFilter: compoundPredicateWithoutFilter)
                        .opacity(!(beaconModel.isDownloadStatusError
                                    || beaconModel.isDownloading
                                    || beaconModel.isDownloadStatusSuccess) ? 1 : 0)
                    //                    BeaconBottomBarStatusFilterButton(
                    //                        filterActive: doFilter,
                    //                        filterByTime: $userSettings.filterByTime,
                    //                        filterByLocation: $userSettings.filterByLocation,
                    //                        filterByFlag: $userSettings.filterByFlag,
                    //                        filterByHidden: $userSettings.filterByHidden,
                    //                        filterByShown: $userSettings.filterByShown,
                    //                        predicate: compoundPredicate)
                    //                        .opacity(!(beaconModel.isDownloadStatusError
                    //                                    || beaconModel.isDownloading
                    //                                    || beaconModel.isDownloadStatusSuccess) ? 1 : 0)
                    
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
                            beaconModel.activeAlert = .downloadError    // TODO
                        } else if doFilter {
                            activeSheet = .filter
                        }
                    }) {
                        HStack { }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                Spacer()
                
                Button(action: {
                    activeSheet = .settings
                }) {
                    HStack {
                        Image(systemName: "ellipsis.circle")
                    }
                    .padding()
                }
            }
        }
        .navigationBarItems(
            leading:
                HStack {
                },
            trailing:
                HStack {
                    Spacer()
                    HStack {
                        if !beaconModel.isBluetoothAuthorization {
                            Text("not available")
                                .foregroundColor(.gray)
                        } else {
                            Button(action: {
                                if beaconModel.doScan {
                                    MyCentralManagerDelegate.shared.stopScanService()
                                    print("navigationBarItems stopScanService")
                                } else {
                                    MyCentralManagerDelegate.shared.startScanService()
                                    print("navigationBarItems startScanService")
                                }
                                os_signpost(.event, log: self.log, name: "Useraction", "scan_%{public}s", beaconModel.doScan ? "y" : "n")
                            }) {
                                HStack {
                                    if beaconModel.doScan {
                                        ProgressCircle(mode: .busy)
//                                        ProgressCircle(rotation: -90,
//                                                       progress: beaconModel.scanTimerCounter / MyCentralManagerDelegate.shared.scanDuration,
//                                                       mode: .timer)
                                    } else {
                                        ProgressCircle(rotation: 0, progress: 0, mode: .idle)
                                    }
                                }
                            }
                            
                        }
                    }
                    .frame(width: 100, alignment: .trailing)
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
        .alert(item: $beaconModel.activeAlert) { item in
            switch item {
            case .downloadError:
                return Alert(
                    title: Text("Download errors"),
                    message: Text("Download sensor data is complete. Retrieval did not succeed for the following sensors:\n\(downloadManager.buildDownloadErrorDeviceList())"),
                    dismissButton: .default(Text("OK"),
                                            action: { downloadManager.clearDownloadErrorAndResume() })
                )
            case .hiddenAlert:
                return Alert(
                    title: Text("Hide sensor"),
                    message: Text("Sensor will be marked as hidden. Find it again using sensor filter."),
                    dismissButton: .default(Text("Got it!"))
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
//
//    public func addNewDevicesEntity_Step1() {
//        print("addNewDevicesEntity Step1")
//        let moc = PersistenceController.shared.container.viewContext
//        moc.perform {
//            let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
//            var localBeacons: [Beacon] = []
//            do {
//                localBeacons = try moc.fetch(fetchRequest)
//            } catch {
//                print("addNewDevicesEntity error")
//                let fetchError = error as NSError
//                debugPrint(fetchError)
//                return
//            }
//
//            print("localBeacons count: \(localBeacons.count)")
//
//            for beacon in localBeacons {
//                print("\(beacon.wrappedDeviceName) \(beacon.devices == nil ? "devices nil" : "devices set")")
//            }
//
//            print("add new Device")
//            let newDevices = Devices(context: moc)
//            print("beacons >")
//            print("\(newDevices.beaconArray)")
//            print("beacons <")
//
//            for beacon in localBeacons {
//                print("set device for \(beacon.wrappedDeviceName)")
//                beacon.devices = newDevices
//            }
//
//            for beacon in localBeacons {
//                print("\(beacon.wrappedDeviceName) \(beacon.devices == nil ? "devices nil" : "devices set")")
//            }
//
//            print("beacons >")
//            print("\(newDevices.beaconArray)")
//            print("beacons <")
//        }
//    }
//
//    public func addNewDevicesEntity_Step2() {
//        print("addNewDevicesEntity Step2")
//        let moc = PersistenceController.shared.container.viewContext
//        moc.perform {
//            print("save new Devices")
//            PersistenceController.shared.saveContext(context: moc)
//
//        }
//    }
//
//    public func addNewDevicesEntity_Step3() {
//        print("addNewDevicesEntity Step3")
//        let moc = PersistenceController.shared.container.viewContext
//        moc.perform {
//            let fetchRequest: NSFetchRequest<Devices> = Devices.fetchRequest()
//            var devices: [Devices] = []
//            do {
//                devices = try moc.fetch(fetchRequest)
//            } catch {
//                print("addNewDevicesEntity3 error")
//                let fetchError = error as NSError
//                debugPrint(fetchError)
//                return
//            }
//
//            print("devices count \(devices.count)")
//            if let devices = devices.first {
//                print("devides contains beacons count \(devices.beaconArray.count)")
//                print("beacons >")
//                print(devices.beaconArray)
//                print("beacons <")
//            }
//
//            print("step 3 done")
//        }
//    }
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
    
    
//    public func resetDistanceBeaconOnce() {
//        print("resetDistanceBeaconOnce")
//        for beacon in beacons {
//            beacon.localDistanceFromPosition = -1
//        }
//    }
//
//    public func listBeaconChanges() {
//        var changesBeacon: [String : Any ] = [:]
//        var changesBeaconAdv: [ String : Any ] = [:]
//        var changesBeaconLocation: [ String : Any ] = [:]
//
//        print("listBeaconChanges")
//        for beacon in beacons {
//            changesBeacon = beacon.changedValues()
//            if let adv = beacon.adv {
//                changesBeaconAdv = adv.changedValues()
//            }
//            if let location = beacon.location {
//                changesBeaconLocation = location.changedValues()
//            }
//            print("\(beacon.wrappedDeviceName) Changes: Beacon \(changesBeacon.count), adv \(changesBeaconAdv.count), location \(changesBeaconLocation.count) Distance \(beacon.localDistanceFromPosition)")
//        }
//    }
//
    static func == (lhs: Self, rhs: Self) -> Bool {
        return false
    }
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
    
}


//struct BeaconList_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconList()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(BeaconModel())
//            .environmentObject(ViewRouter())
//    }
//}
