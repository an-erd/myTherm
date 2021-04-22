import SwiftUI
import CoreData
import OSLog

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared

    var body: some View {
        NavigationView {
            VStack {
                BeaconList()
                    .listStyle(GroupedListStyle())
            }
            .navigationTitle("Sensors")
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear(perform: {
            print("ContentView onAppear")
            PersistenceController.shared.writeContext.perform {
                //                                copyStoreToLocalBeacons()
                let log = OSLog(
                    subsystem: "com.anerd.myTherm",
                    category: "preparation"
                )
                os_signpost(.begin, log: log, name: "copyBeaconHistoryOnce")
                MyCentralManagerDelegate.shared.copyBeaconHistoryOnce()
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
                DispatchQueue.main.async {
                    MyCentralManagerDelegate.shared.copyLocalBeaconsToWriteContext()
                    PersistenceController.shared.writeContext.performAndWait {
                        PersistenceController.shared.saveContext(context: PersistenceController.shared.writeContext)
                    }
                }
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
