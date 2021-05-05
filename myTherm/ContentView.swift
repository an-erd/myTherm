import SwiftUI
import CoreData
import OSLog

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
    private var beaconModel = BeaconModel.shared

    private let log = OSLog(subsystem: "com.anerd.myTherm", category: "preparation")
    
    var body: some View {
        NavigationView {
            VStack {
                BeaconList()
                    .equatable()
                    .listStyle(GroupedListStyle())
            }
            .navigationTitle("Sensors")
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear(perform: {
            print("ContentView onAppear")
            PersistenceController.shared.writeContext.perform {
                os_signpost(.begin, log: log, name: "copyBeaconHistoryOnce")
                beaconModel.copyBeaconHistoryOnce()
                os_signpost(.end, log: log, name: "copyBeaconHistoryOnce")
            }
            MyCentralManagerDelegate.shared.stopScanService()
        })

        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("PHASECHANGE: View entered background")
            case .active:
                print("PHASECHANGE: View entered active")
            case .inactive:
                print("PHASECHANGE: View entered inactive")
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
