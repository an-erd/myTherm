//
//  BeaconLineView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 13.03.21.
//

import SwiftUI

struct BeaconLineView: View {
    
    @ObservedObject var beacon: Beacon
    var displaySteps: Int
    
    var body: some View {
        
        ZStack {
            if displaySteps == 0 {
                if beacon.wrappedLocalHistoryTemperature.count >= 2 {
                    LineView(beacon: beacon, timestamp: beacon.wrappedLocalHistoryTimestamp,
                             data: beacon.wrappedLocalHistoryTemperature, title: "°C")
                        .isHidden(beacon.wrappedLocalHistoryTemperature.count < 2, remove: false)
                } else {
                    Rectangle().fill(Color.green)
                }
            } else if displaySteps == 1 {
                if beacon.wrappedLocalHistoryHumidity.count >= 2 {
                    LineView(beacon: beacon, timestamp: beacon.wrappedLocalHistoryTimestamp,
                             data: beacon.wrappedLocalHistoryHumidity, title: "%")
                        .isHidden(beacon.wrappedLocalHistoryHumidity.count < 2)
                } else {
                    Rectangle().fill(Color.red)
                }
            }
        }
    }
}

//struct BeaconLineView_Previews: PreviewProvider {
//    static var previews: some View {
////        BeaconLineView()
//    }
//}
