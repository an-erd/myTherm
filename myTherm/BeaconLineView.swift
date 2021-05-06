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
    @StateObject var beaconModel = BeaconModel.shared

//    var displaySteps: Int   // 0 temperature, 1 humidity
    
    var titleStrings = ["°C", "%"]
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                GeometryReader{ reader in
                    // hitches
                    ZStack {
                        LineView(
                            timestamp: beacon.wrappedLocalHistoryTimestamp,
                            dataTemperature: beacon.wrappedLocalHistoryTemperature,
                            dataHumidity: beacon.wrappedLocalHistoryHumidity,
                            localValue: localValue,
                            showTemperature: $beaconModel.isShownTemperature,
                            //                isTabbing: $localValue.isTabbing,
                            isDragging: $localValue.isDragging,
                            //                        displaySteps: displaySteps,
                            titleStrings: titleStrings,
                            frameSize: CGRect(x: 0, y: 0,
                                              width: reader.frame(in: .local).width,
                                              height: reader.frame(in: .local).height)
                        )
                        .equatable()
                    }
                    .isHidden(beacon.wrappedLocalHistoryTemperature.count < 2, remove: false)
                }
            }
        }
    }
}

//struct BeaconLineView_Previews_Container : View {
//    var beacon: Beacon = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Beacon }) as! Beacon
//    var localValue = BeaconLocalValueView()
//    var step: Int
//    
//    var body: some View {
//        BeaconLineView(beacon: beacon, localValue: localValue, displaySteps: step)
//    }
//    
//}
//
//struct BeaconLineView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            BeaconLineView_Previews_Container(step: 0)
//            BeaconLineView_Previews_Container(step: 1)
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//    }
//}
