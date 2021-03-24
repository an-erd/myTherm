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
    @StateObject var model = BeaconModel()
//    @StateObject var lm = LocationManager()
    @StateObject var viewRouter = ViewRouter()

    var body: some Scene {
        WindowGroup {
            if !UserDefaults.standard.bool(forKey: "didLaunchBefore") {
                
            }
            MotherView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(model)
//                .environmentObject(lm)
                .environmentObject(viewRouter)
//       ContentView()
//       OnboardingView()
        }
    }
}
