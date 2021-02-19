//
//  BeaconDetail.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct BeaconDetail: View {
    @ObservedObject var beacon: Beacon
    @State var showAlertLastSeen = false
    @State private var isExpandedBeaconInfo: Bool = true
    @State private var isExpandedPayload: Bool = true
    @State private var isExpandedLastSeen: Bool = true

    struct ToggleStates {
        var Sec1: Bool = true
        var Sec2: Bool = true
        var Sec3: Bool = true
        var Sec4: Bool = true
    }
    @State private var toggleStates = ToggleStates()

//    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List {
//                DisclosureGroup("BEACON INFORMATION", isExpanded: $isExpandedBeaconInfo) {
//                    NavigationLink(destination: TextEdit(fieldName: "Name", name:
//                                                            $beacon.name, allowEmpty: false)
//                    ) {
//                        BeaconDetailListEntry(title: "Name", text: beacon.name )
//                    }
//
//                    NavigationLink(destination: TextEdit(fieldName: "Description", name:
//                                                            $beacon.descrNonOptional, allowEmpty: true)
//                    ) {
//                        BeaconDetailListEntry(title: "Description", text:
//                                                beacon.descr ?? "")
//                    }
                }
                
                DisclosureGroup("PAYLOAD", isExpanded: $isExpandedPayload) {
                    buildViewAdv(beaconadv: beacon.adv)
                    if (self.beacon.adv != nil){
                        Button(action: { self.beacon.adv = nil }) {
                            Text("Reset payload data")
                                .foregroundColor(.blue)
                        }
                    }
                }

//                DisclosureGroup("LAST SEEN", isExpanded: $isExpandedLastSeen) {
//                    if beacon.lastSeen == nil &&
//                        beacon.loc == nil {
//                        Text("No data available")
//                            .foregroundColor(.gray)
//
//                    } else {
//                        BeaconDetailListEntry(title: "Seen", text: getDateString(
//                            date: beacon.lastSeen))
//                        if beacon.loc != nil {
//                            BeaconDetailListEntry(title: "Location", text: getDateString(
//                                                    date: beacon.loc!.lastLoc))
//
//                            NavigationLink(destination: BeaconDetail(beacon: beacon)) {
//                                ZStack {
//                                    MapView(centerCoordinate: beacon.loc!.location)
//                                        .frame(width: 200, height: 200)
//                                    Circle()
//                                        .fill(Color.blue)
//                                        .opacity(0.3)
//                                        .frame(width: 32, height: 32)
//                                }
//
//                            }
//
//
//
//                        }
//                        //                        BeaconDetailListEntryWrapper(
//                        //                            title: "Location", location: self.userData.beacons[self.beaconIndex].beaconloc, beaconIndex: beaconIndex)
//                    }
//                    Button(action: { self.showAlertLastSeen = true }) {
//                        Text("Reset last seen date and location data")
//                            .foregroundColor(.blue)
//                    }
//                    .alert(isPresented: $showAlertLastSeen) {
//                        Alert(title: Text("Reset Last Seen Information?"),
//                              message: Text("Date/time and location information for \(beacon.name) will be reset. There is no way to restore this information! Data will be updated with the next beacon advertisement."),
//                              primaryButton: .destructive(Text("Reset")) {
//                                self.beacon.lastSeen = nil
//                                self.beacon.loc = nil
//                                print("Deleting last seen...")
//                            }, secondaryButton: .cancel()
//                        )
//                    }
//                }
                
//            }
//            .navigationBarTitle("\(self.beacon.name)", displayMode: .inline)

        }
        
    }
}

func getDateString(date: Date? ) -> String {
    let formatter2 = DateFormatter()
    formatter2.dateFormat = "yyyy/MM/dd HH:mm:ss"
    
    if let date = date {
        return formatter2.string(from: date)
    } else {
        return "never"
    }
}

func getRssiString(rssi: Int16 ) -> String {
    if rssi == 127 {
        return "(n/a)"
    } else {
        return String(format:"%d dBm", rssi)
    }
}


func buildViewAdv(beaconadv: BeaconAdv?) -> AnyView {
    if let adv = beaconadv {
        return AnyView (
            Group {
                BeaconDetailListEntry(title: "Temperature",
                                      text: String(format:"%.2f °C", adv.temperature))
                BeaconDetailListEntry(title: "Humidity",
                                      text: String(format:"%.2f %%", adv.humidity))
                BeaconDetailListEntry(title: "Battery",
                                      text: String(format:"%d mV", adv.battery))
//                BeaconDetailListEntry(title: "Accel",
//                                      text: String(format:"(%.2f g, %.2f g, %.2f g)",
//                                                   adv.x, adv.y, adv.z))
//                BeaconDetailListEntry(title: "RSSI",
//                                      text: getRssiString(rssi: adv.rssi))
                
//                NavigationLink(destination: TextShow(fieldName: "Raw", text: adv.rawData!)
//                ) {
//                    BeaconDetailListEntry(title: "Raw", text: adv.rawData!)
//                }
            }
        ) } else {
        return AnyView (
            VStack {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        )
    }
}
    
//    @State var showAlertLastSeen = false
//    @State var showAlertIgnore = false
//    @State var showAltertForget = false
//    @State var sectionState: Bool = false
//    @State var deleteBeacon: Bool = false
    
//    func getDateString(date: Date? ) -> String {
//        let formatter2 = DateFormatter()
//        formatter2.dateFormat = "yyyy/MM/dd HH:mm:ss"
//
//        if let date = date {
//            return formatter2.string(from: date)
//        } else {
//            return "none"
//        }
//    }
//
//    func getRssiString(rssi: Int16 ) -> String {
//        if rssi == 127 {
//            return "(n/a)"
//        } else {
//            return String(format:"%d dBm", rssi)
//        }
//    }
    
//    func buildViewAdv(beaconadv: BeaconAdv?) -> AnyView {
//        if let adv = beaconadv {
//            return AnyView (
//                Group {
//                    BeaconDetailListEntry(title: "Temperature",
//                                          text: String(format:"%.2f °C", adv.temperature))
//                    BeaconDetailListEntry(title: "Humidity",
//                                          text: String(format:"%.2f %%", adv.humidity))
//                    BeaconDetailListEntry(title: "Battery",
//                                          text: String(format:"%d mV", adv.battery))
//                    BeaconDetailListEntry(title: "Accel",
//                                          text: String(format:"(%.2f g, %.2f g, %.2f g)",
//                                                       adv.x, adv.y, adv.z))
//                    BeaconDetailListEntry(title: "RSSI",
//                                          text: getRssiString(rssi: adv.rssi))
//
//                    NavigationLink(destination: TextShow(fieldName: "Raw", text: adv.rawData!)
//                    ) {
//                        BeaconDetailListEntry(title: "Raw", text: adv.rawData!)
//                    }
//                }
//            ) } else {
//            return AnyView (
//                VStack {
//                    Text("No data available")
//                        .foregroundColor(.gray)
//                }
//            )
//        }
//    }
    /*
     func BeaconDetailListEntryWrapper(title: String, location: BeaconLoc?, beacon: Beacon) -> AnyView {
     if let location = location {
     return AnyView(
     NavigationLink(destination: BeaconDetailLocation(beacon: $beacon))
     ){
     BeaconDetailListEntry(
     title: title, text: String(format: "%.4f %.4f", location.latitude, location.longitude))
     }
     } else {
     return AnyView( BeaconDetailListEntry(title: title, text: "none"))
     }
     }
     */
    
//    func isExpanded() -> Bool {
//        sectionState
//    }
    
                
//                Section() {
//                    NavigationLink(destination: TextEdit(fieldName: "Name", name:
//                        $beacon.nameNonOptional, allowEmpty: false)
//                    ) {
//                        BeaconDetailListEntry(title: "Name", text:
//                            beacon.name ?? "")
//                    }
//                    NavigationLink(destination: TextEdit(fieldName: "Description", name:
//                        $beacon.descrNonOptional, allowEmpty: true)
//                    ) {
//                        BeaconDetailListEntry(title: "Description", text:
//                            beacon.descr ?? "")
//                    }
//
//                }
//                Section(header: Text("PAYLOAD"), footer:
//                    Button(action: {
//                        self.beacon.adv = nil
//                    }) {
//                        Text("Reset payload data")
//                    }
//                ) {
//                    buildViewAdv(beaconadv: beacon.adv)
//                }
//                Section(header: Text("LAST SEEN"), footer:
//                    Button(action: {
//                        self.showAlertLastSeen = true
//                    }) {
//                        Text("Reset last seen date and location data")
//                    }
//                    .alert(isPresented: $showAlertLastSeen) {
//                        Alert(title: Text("Reset Last Seen Information?"),
//                              message: Text("Date/time and location information for \(beacon.name ?? "") will be reset. There is no way to restore this information! Data will be updated with the next beacon advertisement."),
//                              primaryButton: .destructive(Text("Reset")) {
//                                self.beacon.lastSeen = nil
//                                self.beacon.loc = nil
//                                print("Deleting last seen...")
//                            }, secondaryButton: .cancel()
//                        )
//                    }
//                ) {
//                    if beacon.lastSeen == nil &&
//                        beacon.loc == nil {
//                        Text("No data available")
//                            .foregroundColor(.gray)
//
//                    } else {
//
//                        BeaconDetailListEntry(title: "Date", text: getDateString(
//                            date: beacon.lastSeen))
//
//                        //                        BeaconDetailListEntryWrapper(
//                        //                            title: "Location", location: self.userData.beacons[self.beaconIndex].beaconloc, beaconIndex: beaconIndex)
//                    }
//
//                }
//
//                Section(header: Text("OTHER")) {
//                    Button(action: {
//                        self.sectionState.toggle() }) {
//                            BeaconDetailListCollExpEntry(title: "Header + Vendor Data",
//                                                         isExpanded: self.sectionState)
//                    }
//                    if self.isExpanded() {
//                        BeaconDetailListEntry(title: "Company ID",
//                                              text:String(self.beacon.companyId))
//                        BeaconDetailListEntry(title: "Device Type",
//                                              text:String(self.beacon.type))
//                        BeaconDetailListEntry(title: "Length of advertised data",
//                                              text:String(self.beacon.length))
//                        BeaconDetailListEntry(title: "UUID",
//                                              text:self.beacon.uuid ?? "" )
//                        BeaconDetailListEntry(title: "MAJ",
//                                              text:self.beacon.maj ?? "" )
//                        BeaconDetailListEntry(title: "MIN",
//                                              text: self.beacon.min!)
//                        BeaconDetailListEntry(title: "Measured Power",
//                                              text: String(format: "%d", self.beacon.measuredPower))
//                    }
//
//                }
//
//                Section() {
//                    if self.beacon.isMyBeacon {
//                        Button(action: {
//                            self.showAlertIgnore = true
//                        }) {
//                            Text("Remove from My Beacons")
//                                .foregroundColor(.blue)
//                        }
//                        .alert(isPresented: $showAlertIgnore) {
//                            Alert(title: Text("Remove from My Beacons?"),
//                                  message: Text("\(beacon.name ?? "noname") will be removed from My Beacons."),
//                                  primaryButton: .destructive(Text("Remove")) {
//                                    print("Removing from my beacons...")
////                                    self.presentationMode.wrappedValue.dismiss()
////                                    self.beacon.update(attribute: false)
//                                }, secondaryButton: .cancel()
//                            )
//                        }
//                    }
//
//                    Button(action: {
//                        self.showAltertForget = true
//                    }) {
//                        Text("Ignore beacon")
//                            .foregroundColor(.blue)
//                    }
//                    .alert(isPresented: $showAltertForget) {
//                        Alert(title: Text("Forget Beacon?"),
//                              message: Text("\(beacon.name ?? "noname") will be ignored and can be added to MY BEACONS using the context menu or detail view."),
//                              primaryButton: .destructive(Text("Ignore")) {
//                                print("Forgetting...")
//                                self.presentationMode.wrappedValue.dismiss()
//                                self.beacon.update(attribute: Attribute.getAttribute(order: 2))
//
////                                self.deleteBeacon = true
////                                self.beacon.delete()
//                            }, secondaryButton: .cancel()
//                        )
//                    }
//                }
//            }
//            .navigationBarTitle("\(self.beacon.name ?? "")", displayMode: .inline)
////                    .onDisappear(
////            //            if self.deleteBeacon {
////                        self.beacon.delete()
////                        )
//        }
//    }
//}

/*
 #if DEBUG
 struct BeaconDetail_Preview: PreviewProvider {
 static var previews: some View {
 let userData = UserData()
 return BeaconDetail(beacon: beacons[0])
 .environmentObject(userData)
 }
 }
 #endif
 */
