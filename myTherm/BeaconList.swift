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
    let hapticsManager = HapticsManager.shared
    @StateObject var downloadManager = DownloadManager.shared
    @StateObject var lm = LocationManager.shared
    var authMode = LocationManager.shared.locationAuthorizationStatus
    
    @State private var editMode: EditMode = .inactive
    @State private var doFilter: Bool = false
    @State var activeSheet: ActiveSheet?
    @State var activeSheetDismiss: ActiveSheet?
    @State var predicateTimeFilter: NSPredicate?
    @State var predicateLocationFilter: NSPredicate?
    @State var predicateFlaggedFilter: NSPredicate?
    @State var predicateHiddenFilter: NSPredicate?
    @State var predicateShownFilter: NSPredicate?
    @State var predicateLowBatteryFilter: NSPredicate?
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
        
        if userSettings.filterByLowBattery {
            predicateLowBatteryFilter = NSPredicate(format: "lowBattery == true")
            if let predicateLowBatteryFilter = predicateLowBatteryFilter {
                compound.append(predicateLowBatteryFilter)
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
    
    fileprivate func buildViewPullingDown() -> some View {
        return AnyView(
            VStack {
                Text("Pull down to scan for sensors")
//                DefaultIndicatorView()
            }
        )
    }
    
    fileprivate func buildViewPulledDown() -> some View {
        return AnyView(
            Text("Scanning for sensors now...")
        )
    }
    
    
    func loadMore() async {
        print("loadMore")
    }

    var body: some View {
        
        ZStack {
            VStack {
                if beaconModel.isPulledDown {
                    buildViewPulledDown()
                } else if beaconModel.pullingDownThreshold {
                    buildViewPullingDown()
                }
                Spacer()
            }
            .offset(y: -50)
            ScrollView {
                VStack {
                    VStack(spacing: 8) {
                        buildViewBluetoothAutorization()
                        buildViewLocationServices()
                        buildViewInternet()
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
                        if !beaconModel.isScrolling {
                            beaconModel.isScrolling = true
                        }
                        if val < -100 {
                            if beaconModel.isPulledDown == false {
                                beaconModel.isPulledDown = true
                                MyCentralManagerDelegate.shared.startScanService()
                                HapticsManager.shared?.playPull()
                            }
                        } else if val < -80 {
                            beaconModel.pullingDownThreshold = true
                        } else if val < -30 {
                            beaconModel.pullingDownThreshold = false
                        }  else {
                            if beaconModel.isPulledDown {
                                beaconModel.isPulledDown = false
                            }
                        }
                        detector.send(val)
                    }
                }
            }
//            .refreshable {
//                await loadMore()
//            }

            .coordinateSpace(name: "scroll")
            .onReceive(publisher) {
                print("Stopped scroll on: \($0)")
                beaconModel.isScrolling = false
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
                            filterByShown: $userSettings.filterByShown,
                            filterByLowBattery: $userSettings.filterByLowBattery,
                            compoundPredicateWithFilter: compoundPredicateWithFilter,
                            compoundPredicateWithoutFilter: compoundPredicateWithoutFilter)
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
                    
                    //                Button(action: {
                    //                    activeSheet = .settings
                    //                }) {
                    //                    HStack {
                    //                        Image(systemName: "ellipsis.circle")
                    //                    }
                    //                    .padding()
                    //                }
                }
            }
        }

        //        .navigationBarItems(
        //            leading:
        //                HStack {
        //                },
        //            trailing:
        //                HStack {
        //                    Spacer()
        //                    HStack {
        //                        if !beaconModel.isBluetoothAuthorization {
        //                            Text("not available")
        //                                .foregroundColor(.gray)
        //                        } else {
        //                            Button(action: {
        //                                if beaconModel.doScan {
        //                                    MyCentralManagerDelegate.shared.stopScanService()
        //                                    print("navigationBarItems stopScanService")
        //                                } else {
        ////                                    MyCentralManagerDelegate.shared.startScanService()
        ////                                    print("navigationBarItems startScanService")
        //                                }
        //                                os_signpost(.event, log: self.log, name: "Useraction", "scan_%{public}s", beaconModel.doScan ? "y" : "n")
        //                            }) {
        //                                HStack {
        //                                    if beaconModel.doScan {
        //                                        ProgressCircle(mode: .busy)
        ////                                        ProgressCircle(rotation: -90,
        ////                                                       progress: beaconModel.scanTimerCounter / MyCentralManagerDelegate.shared.scanDuration,
        ////                                                       mode: .timer)
        //                                    } else {
        //                                        ProgressCircle(rotation: 0, progress: 0, mode: .idle)
        //                                    }
        //                                }
        //                            }
        //
        //                        }
        //                    }
        //                    .frame(width: 100, alignment: .trailing)
        //                }
        //        )
//        .border(Color.red)
        .sheet(item: $activeSheet) { item in
            switch item {
            case .filter:
                BeaconFilterSettingsSheet(filterByTime: $userSettings.filterByTime,
                                          filterByLocation: $userSettings.filterByLocation,
                                          filterByFlag: $userSettings.filterByFlag,
                                          filterByHidden: $userSettings.filterByHidden,
                                          filterByShown: $userSettings.filterByShown,
                                          filterByLowBattery: $userSettings.filterByLowBattery)
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
