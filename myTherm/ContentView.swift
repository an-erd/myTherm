import SwiftUI
import CoreData
import OSLog

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
    private var beaconModel = BeaconModel.shared

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
//                                                copyStoreToLocalBeacons()
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
                // if not in history downloading:
                if !beaconModel.scanUpdateTemporaryStopped {
                    print(".onChange \(Thread.current)")
                    MyCentralManagerDelegate.shared.copyLocalBeaconsToWriteContext()
                    
                    // TODO delete history
//                    let moc = PersistenceController.shared.newTaskContext()
//                    moc.performAndWait {
//                        print(".onChange deleteHistory")
//                        do {
//                            try deleteHistory(in: moc)
//                        } catch let error as NSError  {
//                            print("Could not delete history \(error), \(error.userInfo)")
//                        }
//                        PersistenceController.shared.saveContext(context: moc)
//                    }
                }
            @unknown default:
                print("PHASECHANGE: View entered unknown phase.")
            }
        }
    }
}

public func deleteHistory(in context: NSManagedObjectContext) throws {
    guard #available(iOSApplicationExtension 11.0, *) else { return }

    let currentDate = Date()
    var dateComponent = DateComponents()
    dateComponent.day = -7

    guard let timestamp = Calendar.current.date(byAdding: dateComponent, to: currentDate) else { return }
    let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
    try! context.execute(deleteHistoryRequest)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ViewRouter())

        
    }
}
