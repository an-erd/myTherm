import SwiftUI
import CoreData
import OSLog

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
//    private var beaconModel = BeaconModel.shared
    @StateObject var beaconModel = BeaconModel.shared


    private let log = OSLog(subsystem: "com.anerd.myTherm", category: "preparation")
    
    var body: some View {
//            VStack {
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
//                                }
//                                os_signpost(.event, log: self.log, name: "Useraction", "scan_%{public}s", beaconModel.doScan ? "y" : "n")
//                            }) {
//                                HStack {
//                                    if beaconModel.doScan {
//                                        ProgressCircle(mode: .busy)
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
//
////                Spacer()
//            }
            

        NavigationView {
            ZStack {
                VStack {
//                    if beaconModel.isScrollUpdate {
//                        VStack {
//                            ProgressView()
//                                .scaleEffect(1.5, anchor: .center)
//                            VStack {
//                                Text("Pull and release to scan for sensors")
//                            }
//                            .font(.headline)
//                            .foregroundColor(.secondary)
//                            .padding()
//                        }
                        Spacer()
//                    }
                }
                .frame(height: 12)
//                .offset(y:30)
                .border(Color.green)
                
                withAnimation {
                    VStack {
                        BeaconList()
                            .equatable()
                            .listStyle(GroupedListStyle())
                    }
//                    .offset(y: beaconModel.isScrollUpdate ? 120 : 0)   // EXPERIMENT
                }
                //                .navigationBarTitle("", displayMode: .inline)
                //                .navigationBarHidden(true)
                .navigationTitle("Sensors")
                .navigationViewStyle(StackNavigationViewStyle())
            }
//                .navigationBarItems(
//                    leading:
//                        HStack {
//                        },
//                    trailing:
//                        HStack {
//                            Spacer()
//                            HStack {
//                                if !beaconModel.isBluetoothAuthorization {
//                                    Text("not available")
//                                        .foregroundColor(.gray)
//                                } else {
//                                    Button(action: {
//                                        if beaconModel.doScan {
//                                            MyCentralManagerDelegate.shared.stopScanService()
//                                            print("navigationBarItems stopScanService")
//                                        } else {
//        //                                    MyCentralManagerDelegate.shared.startScanService()
//        //                                    print("navigationBarItems startScanService")
//                                        }
//                                        os_signpost(.event, log: self.log, name: "Useraction", "scan_%{public}s", beaconModel.doScan ? "y" : "n")
//                                    }) {
//                                        HStack {
//                                            if beaconModel.doScan {
//                                                ProgressCircle(mode: .busy)
//        //                                        ProgressCircle(rotation: -90,
//        //                                                       progress: beaconModel.scanTimerCounter / MyCentralManagerDelegate.shared.scanDuration,
//        //                                                       mode: .timer)
//                                            } else {
//                                                ProgressCircle(rotation: 0, progress: 0, mode: .idle)
//                                            }
//                                        }
//                                    }
//
//                                }
//                            }
//                            .frame(width: 100, alignment: .trailing)
//                        }
//                )

//            }

        }
        .navigationViewStyle(StackNavigationViewStyle())

        .onAppear(perform: {
            print("ContentView onAppear")
            PersistenceController.shared.writeContext.perform {
                let writeMoc = PersistenceController.shared.writeContext    // 1) prepare local history
                let viewMoc = PersistenceController.shared.viewContext      // 2) copy to view context
                beaconModel.copyBeaconHistoryOnce(contextFrom: writeMoc, contextTo: viewMoc)
            }
            MyCentralManagerDelegate.shared.stopScanService()
        })

        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("PHASECHANGE: View entered background")
                os_signpost(.event, log: self.log, name: "Useraction", "phase_background")
            case .active:
                print("PHASECHANGE: View entered active")
                os_signpost(.event, log: self.log, name: "Useraction", "phase_active")
            case .inactive:
                print("PHASECHANGE: View entered inactive")
                os_signpost(.event, log: self.log, name: "Useraction", "phase_inactive")
                beaconModel.copyLocalBeaconsToWriteContext()
            @unknown default:
                print("PHASECHANGE: View entered unknown phase.")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ViewRouter())

        
    }
}
