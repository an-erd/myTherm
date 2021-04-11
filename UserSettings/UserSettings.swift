//
//  UserSettings.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 11.04.21.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var didLaunchBefore: Bool {
        didSet {
            UserDefaults.standard.set(didLaunchBefore, forKey: "didLaunchBefore")
        }
    }

    @Published var showRequestLocationAlert: Bool {
        didSet {
            UserDefaults.standard.set(showRequestLocationAlert, forKey: "showRequestLocationAlert")
        }
    }

    init() {
        self.didLaunchBefore = (UserDefaults.standard.object(forKey: "didLaunchBefore") == nil ? false :
                                    UserDefaults.standard.object(forKey: "didLaunchBefore") as! Bool)

        self.showRequestLocationAlert = (UserDefaults.standard.object(forKey: "showRequestLocationAlert") == nil ? true :
                                            UserDefaults.standard.object(forKey: "showRequestLocationAlert") as! Bool)
    }
}
