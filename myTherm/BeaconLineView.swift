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

struct BeaconLineView_Previews_Container : View {
    var beacon: Beacon = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Beacon }) as! Beacon
    var localValue = BeaconLocalValueView()
    var step: Int
    
    var body: some View {
        BeaconLineView(beacon: beacon, localValue: localValue, displaySteps: step)
    }
    
}

struct BeaconLineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BeaconLineView_Previews_Container(step: 0)
            BeaconLineView_Previews_Container(step: 1)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
