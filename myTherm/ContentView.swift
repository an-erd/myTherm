import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    
    let locationManager = CLLocationManager()

    var body: some View {
        NavigationView {
            BeaconList()
                .navigationBarTitle("Beacons")
                .toolbar {
                    EditButton()
                }
                .listStyle(GroupedListStyle())
                .navigationBarItems(trailing: EditButton() )
        }
        .onAppear {
            MyBluetoothManager.shared.setMoc(moc: viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("PHASECHANGE: View entered background")
            case .active:
                print("PHASECHANGE: View entered active")
            case .inactive:
                print("PHASECHANGE: View entered inactive")
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
