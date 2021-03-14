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
                .listStyle(GroupedListStyle())
//                .navigationBarItems(trailing:
//                    ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
//                    )
        }
        
        .navigationBarItems(
            trailing: Button(action: {
                MyBluetoothManager.shared.downloadManager.addAllBeaconToDownloadQueue()
            }) {
                Image(systemName: "icloud.and.arrow.down")
                //                Image(systemName: "arrow.triangle.2.circlepath")
                //                ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
            }
            
            //                    ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
        )
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
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    print("Filter pressed")
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                Spacer()
                Text("status text")
                Spacer()
                Button("Second") {
                    print("Pressed")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
