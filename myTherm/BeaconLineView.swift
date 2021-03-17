//
//  BeaconLineView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 13.03.21.
//

import SwiftUI

struct BeaconLineView: View {
    
    @ObservedObject var beacon: Beacon
    var displaySteps: Int   // 0 temperature, 1 humidity
    var titleStrings = ["°C", "%"]
    
    var body: some View {
        
        ZStack {
            LineView(beacon: beacon, displaySteps: displaySteps, titleStrings: titleStrings)
                .isHidden(beacon.wrappedLocalHistoryTemperature.count < 2, remove: false)
        }
    }
}

//struct BeaconLineView_Previews: PreviewProvider {
//    static var previews: some View {
////        BeaconLineView()
//    }
//}
