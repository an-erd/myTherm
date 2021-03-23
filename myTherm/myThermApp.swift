//
//  myThermApp.swift
//  myTherm
//
//  Created by Andreas Erdmann on 17.02.21.
//

import SwiftUI
import CoreLocation

@main
struct myThermApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var lm = LocationManager()
    @StateObject var model = BeaconModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(lm)
                .environmentObject(model)
        }
    }
}
