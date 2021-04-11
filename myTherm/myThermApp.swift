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
    @StateObject var viewRouter = ViewRouter()
    @StateObject var userSettings = UserSettings()

    func setViewRouterPage(page: String) -> AnyView {
        viewRouter.currentPage = page
        userSettings.didLaunchBefore = true
        return AnyView(EmptyView())
    }
    var body: some Scene {
        WindowGroup {
            if !userSettings.didLaunchBefore {
                setViewRouterPage(page: "onboarding")
            }
            MotherView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(model)
                .environmentObject(viewRouter)
                .environmentObject(userSettings)
        }
    }
}
