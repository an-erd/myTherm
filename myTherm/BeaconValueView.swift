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

    /*
     0-15 secs:             now
     15-180:                recently
     180/3m -3600/60min:    x minutes ago
     60min - 10h            x hours ago
     >10h:                  last seen (short date)
     */
    func getDateInterpretationString(referenceDate: Date, date: Date? ) -> String {
        let formatter2 = DateFormatter()
        let _ = nowDate
        formatter2.dateFormat = "yy/MM/dd"

        if let date = date {
            let secs = date.timeIntervalSinceNow
            if secs > -15 {
                return "Now"
            } else if secs > -180 {
                return "Recently"
            } else if secs > -3600 {
                return "\(-round(secs/60.0)) min. ago"
            } else if secs > -(10*3600) {
                return "\(-round(secs/3600)) hour ago"
            } else {
                return "Seen " + formatter2.string(from: date)
            }
        } else {
            return "Never"
        }
    }

    func getTempValue(beaconadv: BeaconAdv?) -> String {
        guard let beaconadv = beaconadv else {
            return "-"
        }
        return String(format:"%.1f", beaconadv.temperature)
    }
    
    func getHumValue(beaconadv: BeaconAdv?) -> String {
        guard let beaconadv = beaconadv else {
            return String("-")
        }
        return String(format:"%.1f", beaconadv.humidity)
    }

    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                if beacon.adv != nil {
                    Text(getTempValue(beaconadv: beacon.adv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" °C").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)

                    Text(getHumValue(beaconadv: beacon.adv)).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" %").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
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
