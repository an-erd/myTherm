import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    
    let persistenceController = PersistenceController.shared
    @StateObject var lm = LocationManager()
    @StateObject var model = BeaconModel.shared

    let locationManager = CLLocationManager()
    
    var body: some View {
        NavigationView {
            VStack {
//                if !model.isBluetoothAuthorization {
//                    BeaconListAlertEntry(title: "Bluetooth not authorized",
//                                         image: "exclamationmark.triangle.fill",
//                                         text: "Bluetooth authorization necessary. ")
//                }
                BeaconList()
                    .navigationBarTitle("Beacons")
                    .listStyle(GroupedListStyle())
                    .environmentObject(lm)

            }
        }
        .onAppear {
            MyBluetoothManager.shared.setMoc(moc: viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("PHASECHANGE: View entered background")
                PersistenceController.shared.saveBackgroundContext(backgroundContext: viewContext)
            case .active:
                print("PHASECHANGE: View entered active")
            case .inactive:
                print("PHASECHANGE: View entered inactive")
                PersistenceController.shared.saveBackgroundContext(backgroundContext: viewContext)
            @unknown default:
                print("PHASECHANGE: View entered unknown phase.")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
