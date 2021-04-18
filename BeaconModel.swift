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
    
    @Published var isDownloading: Bool = false
    @Published var isDownloadStatusError: Bool = false
    @Published var isDownloadStatusSuccess: Bool = false
    
    @Published var textDownloadingStatusLine1: String = ""
    @Published var textDownloadingStatusLine2: String = ""

    @Published var numDownloadStatusError: Int = 0
    @Published var textDownloadStatusErrorLine1: String = ""
    @Published var textDownloadStatusErrorLine2: String = ""

    @Published var isUpdatingSensor: Bool = false
    static var shared = BeaconModel()

}
