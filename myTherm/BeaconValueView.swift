//
//  BeaconValueView.swift
//  TestNew3
//
//  Created by Andreas Erdmann on 19.08.20.
//

import SwiftUI

struct BeaconValueView: View {
    
    @ObservedObject var beacon: Beacon
    var nowDate: Date
    
    func getTempValue(beaconadv: BeaconAdv) -> String {
        return String(format:"%.1f", beaconadv.temperature)
    }
    
    func getHumValue(beaconadv: BeaconAdv) -> String {
        return String(format:"%.1f", beaconadv.humidity)
    }
    
    func getTempValue(beacon: Beacon) -> String {
        return String(format:"%.1f", beacon.localDragTemperature)
    }
    
    func getHumValue(beacon: Beacon) -> String {
        return String(format:"%.1f", beacon.localDragHumidity)
    }
    
    @ScaledMetric var size: CGFloat = 1
    
    // TODO
    // adjust using https://www.swiftbysundell.com/tips/optional-swiftui-views/
    @ViewBuilder var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            if beacon.localDragMode {
                HStack(spacing: 5) {
                    Text(getTempValue(beacon: beacon)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" °C").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    
                    Text(getHumValue(beacon: beacon)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" %").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    Spacer()
                }
                if let date = beacon.localDragTimestamp {
                    Text(getDateString(date: date))
                        .font(.footnote).foregroundColor(.secondary) //.padding(.trailing, 4)
                } else {
                    Text("no date")
                }
            } else {
                Unwrap(beacon.adv) { beaconadv in
                    HStack(spacing: 5) {
                        Text(getTempValue(beaconadv: beaconadv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" °C").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                        
                        Text(getHumValue(beaconadv: beaconadv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" %").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                        Spacer()
                    }
                }
                Text(beacon.wrappedAdvDateInterpretation(nowDate: nowDate))
                    .font(.footnote).foregroundColor(.secondary) //.padding(.trailing, 4)
            }
            
        }
    }
}


//struct BeaconValueView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 8) {
//                    GroupBox(label: Label("Bx0706", systemImage: "thermometer")) {
//                        BeaconValueView(description: "descr",
//                                        temperature: "22,3",
//                                        humidity: "69")
//                    }
//                    .groupBoxStyle(BeaconGroupBoxStyle(color: .blue, destination: Text("Bx070dd6"), dateString: "recently"))
//                }.padding()
//            }.background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.bottom)
//            .navigationTitle("Beacons")
//        }
//    }
//}
