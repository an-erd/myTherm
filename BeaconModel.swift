//
//  BeaconModel.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 22.03.21.
//

import Foundation

final class BeaconModel: ObservableObject {
    
    @Published var isBluetoothAuthorization: Bool = true
    @Published var isShownTemperature: Bool = true
    
    static var shared = BeaconModel()

}
