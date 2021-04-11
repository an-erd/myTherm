import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var lm = LocationManager()
    let persistenceController = PersistenceController.shared

    var body: some View {
        NavigationView {
            VStack {
                BeaconList()
                    .listStyle(GroupedListStyle())
                    .environmentObject(lm)
            }
            .navigationTitle("Sensors")
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("PHASECHANGE: View entered background")
                // TODO bring update to writeContext first
//                PersistenceController.shared.saveContext(context: persistenceController.writeContext)
            case .active:
                print("PHASECHANGE: View entered active")
            case .inactive:
                print("PHASECHANGE: View entered inactive")
                // TODO bring update to writeContext first
//                PersistenceController.shared.saveContext(context: persistenceController.writeContext)
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
