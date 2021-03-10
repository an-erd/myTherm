//
//  BeaconListEntry.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 13.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//
import SwiftUI
import Foundation
import Combine
import CoreData

struct BeaconListEntry : View {
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
                return "\(Int(-round(secs/60.0))) min. ago"
            } else if secs > -(10*3600) {
                return "\(Int(-round(secs/3600))) hour ago"
            } else {
                return "Seen " + formatter2.string(from: date)
            }
        } else {
            return "Never"
        }
    }

    func buildView(beaconadv: BeaconAdv?) -> AnyView {
        if let adv = beaconadv {
            return AnyView (
                HStack {
                    Text(verbatim: String(format:"%.3f °C", adv.temperature))
                    Text(verbatim: String(format:"%.3f %%", adv.humidity))
                }
            )
        } else {
            return AnyView( HStack { Text("(no data)") })
        }
    }

    func buildView(description: String?) -> AnyView {
        if let descr = description {
            return AnyView (
                HStack {
                    Text(verbatim: descr)
                    Text("•")
                }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            )
        } else {
            return AnyView( EmptyView() )
        }
    }
    
    func buildView(lastseen: Date?) -> AnyView {
        return AnyView (
            Text(verbatim: getDateInterpretationString(referenceDate: nowDate, date: lastseen))
                .font(.subheadline)
                .foregroundColor(.gray)
        )
    }

//    func buildView(loc: BeaconLoc?) -> AnyView {
//        if loc != nil {
//            return AnyView (
//                HStack {
//                    Image(systemName: "location.fill")
//                        .imageScale(.small)
//                        .foregroundColor(.gray)
//                }
//            )
//        } else {
//            return AnyView( EmptyView() )
//        }
//    }
    
    var body: some View {
        HStack {
            Image(systemName: "thermometer")
                .frame(width: CGFloat(15.0), height: CGFloat(10.0), alignment: .leading)
            VStack (alignment: .leading, spacing: 0) {
                HStack {
                    Text(verbatim: beacon.name! )
                    Spacer()
                    buildView(beaconadv: beacon.adv)
                }
                HStack {
                    buildView(description: beacon.descr)
                    buildView(lastseen: beacon.adv!.timestamp)
//                    buildView(loc: beacon.loc)
            }
        }

    }
}
}

/*
 #if DEBUG
 struct BeaconListEntry_Previews : PreviewProvider {
 static var previews: some View {
 Group {
 BeaconListEntry(beacon: beaconData[0])
 BeaconListEntry(beacon: beaconData[1])
 }
 .previewLayout(.fixed(width: 300, height: 70))
 }
 }
 #endif
 */
