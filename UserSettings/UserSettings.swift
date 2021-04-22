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

    @Published var showRequestInternetAlert: Bool {
        didSet {
            UserDefaults.standard.set(showRequestInternetAlert, forKey: "showRequestInternetAlert")
        }
    }
    
    @Published var filterByTime: Bool {
        didSet {
            UserDefaults.standard.set(filterByTime, forKey: "filterByTime")
        }
    }
    @Published var filterByLocation: Bool {
        didSet {
            UserDefaults.standard.set(filterByLocation, forKey: "filterByLocation")
        }
    }
    @Published var filterByFlag: Bool {
        didSet {
            UserDefaults.standard.set(filterByFlag, forKey: "filterByFlag")
        }
    }
    @Published var filterByHidden: Bool {
        didSet {
            UserDefaults.standard.set(filterByHidden, forKey: "filterByHidden")
        }
    }
    @Published var filterByShown: Bool {
        didSet {
            UserDefaults.standard.set(filterByHidden, forKey: "filterByShown")
        }
    }

    init() {
        self.didLaunchBefore = (UserDefaults.standard.object(forKey: "didLaunchBefore") == nil ? false :
                                    UserDefaults.standard.object(forKey: "didLaunchBefore") as! Bool)
        
//        UserDefaults.standard.set(true, forKey: "showRequestLocationAlert")
//        UserDefaults.standard.set(true, forKey: "showRequestInternetAlert")
        
        self.showRequestLocationAlert = (UserDefaults.standard.object(forKey: "showRequestLocationAlert") == nil ? true :
                                            UserDefaults.standard.object(forKey: "showRequestLocationAlert") as! Bool)
        self.showRequestInternetAlert = (UserDefaults.standard.object(forKey: "showRequestInternetAlert") == nil ? true :
                                            UserDefaults.standard.object(forKey: "showRequestInternetAlert") as! Bool)
  
        
        self.filterByTime = (UserDefaults.standard.object(forKey: "filterByTime") == nil ? true :
                                            UserDefaults.standard.object(forKey: "filterByTime") as! Bool)
        self.filterByLocation = (UserDefaults.standard.object(forKey: "filterByLocation") == nil ? false :
                                            UserDefaults.standard.object(forKey: "filterByLocation") as! Bool)
        self.filterByFlag = (UserDefaults.standard.object(forKey: "filterByFlag") == nil ? false :
                                            UserDefaults.standard.object(forKey: "filterByFlag") as! Bool)
        self.filterByHidden = (UserDefaults.standard.object(forKey: "filterByHidden") == nil ? false :
                                            UserDefaults.standard.object(forKey: "filterByHidden") as! Bool)
        self.filterByShown = (UserDefaults.standard.object(forKey: "filterByShown") == nil ? false :
                                            UserDefaults.standard.object(forKey: "filterByShown") as! Bool)
    }
}
