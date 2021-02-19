//
//  BeaconValueView.swift
//  TestNew3
//
//  Created by Andreas Erdmann on 19.08.20.
//

import SwiftUI

struct BeaconValueView: View {
    
    @ObservedObject var beacon: Beacon
    @ObservedObject var beaconAdv: BeaconAdv
    var nowDate: Date

    func getTempValue(beaconadv: BeaconAdv) -> String {
        return String(format:"%.1f", beaconadv.temperature)
    }
    
    func getHumValue(beaconadv: BeaconAdv) -> String {
        return String(format:"%.1f", beaconadv.humidity)
    }

    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                if beacon.adv != nil {
                    Text(getTempValue(beaconadv: beaconAdv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" °C").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)

                    Text(getHumValue(beaconadv: beaconAdv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" %").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    Spacer()
                } else {
                    Text("no data").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    Spacer()
                }
            }
            Text(beacon.descr ?? "descr")
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
