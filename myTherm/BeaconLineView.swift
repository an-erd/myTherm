//
//  BeaconLineView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 13.03.21.
//

import SwiftUI

struct BeaconLineView: View {
    
    @ObservedObject var beacon: Beacon
    @ObservedObject var localValue: BeaconLocalValueView
    var displaySteps: Int   // 0 temperature, 1 humidity
    
    var titleStrings = ["°C", "%"]
    
    var body: some View {
        
        ZStack {
            LineView(
                beacon: beacon,
                localValue: localValue,
                isDrag: $localValue.dragMode,
                displaySteps: displaySteps,
                titleStrings: titleStrings)
                .isHidden(beacon.wrappedLocalHistoryTemperature.count < 2, remove: false)
        }
    }
}

//struct BeaconLineView_Previews: PreviewProvider {
//    static var previews: some View {
////        BeaconLineView()
//    }
//}
