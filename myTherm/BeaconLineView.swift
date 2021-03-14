//
//  BeaconLineView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 13.03.21.
//

import SwiftUI

struct BeaconLineView: View {
    
    @ObservedObject var beacon: Beacon
    @State var displaySteps: Int
    
    var body: some View {
        
        ZStack {
            if displaySteps == 0 {
                    LineView(timestamp: beacon.wrappedLocalHistoryTimestamp,
                             data: beacon.wrappedLocalHistoryTemperature, title: "°C")
                        .isHidden(beacon.wrappedLocalHistoryTemperature.count < 2, remove: false)
            } else if displaySteps == 1 {
                if beacon.wrappedLocalHistoryHumidity.count > 2 {
                    LineView(timestamp: beacon.wrappedLocalHistoryTimestamp,
                             data: beacon.wrappedLocalHistoryHumidity, title: "%")
                        .isHidden(beacon.wrappedLocalHistoryHumidity.count < 2)
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
