//
//  BeaconModel.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 22.03.21.
//

import Foundation

final class BeaconModel: ObservableObject {
    
    @Published var isPresentingSettingsView: Bool = false
    @Published var isBluetoothAuthorization: Bool = false
    
    static var shared = BeaconModel()

}
