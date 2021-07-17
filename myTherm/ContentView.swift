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
        NavigationView {
            ZStack {
                VStack {
                    if beaconModel.isScrollUpdate {
                        VStack {
                            ProgressView()
                                .scaleEffect(2, anchor: .center)
                            Text("Scan for Sensors")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        Spacer()
                    }
                }
                VStack {
                    BeaconList()
                        .equatable()
                        .listStyle(GroupedListStyle())
                }
                .navigationTitle("Sensors")
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
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
