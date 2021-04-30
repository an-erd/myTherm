import SwiftUI
import MapKit
import Combine

struct BeaconDetail: View {
    @EnvironmentObject var lm: LocationManager
    @ObservedObject var beacon: Beacon
    
    @State private var isExpandedBeaconInfo: Bool = false
    @State private var isExpandedPayload: Bool = false
    @State private var isExpandedLastSeen: Bool = true
    @State private var isExpandedLocation: Bool = true

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: TextEdit(fieldName: "Name", name: Binding($beacon.name)!,
                                                     allowEmpty: false)
                ) {
                    BeaconDetailListEntry(title: "Name", text: beacon.name ?? beacon.wrappedDeviceName )
                }

                NavigationLink(destination: TextEdit(fieldName: "Description",
                                                     name: $beacon.descrNonOptional, allowEmpty: true)
                ) {
                    BeaconDetailListEntry(title: "Description", text: beacon.descr ?? "")
                }

                DisclosureGroup("BEACON INFORMATION", isExpanded: $isExpandedBeaconInfo) {
                    BeaconDetailListEntry(title: "Device Name", text: beacon.wrappedDeviceName)
                    buildViewBeacon(beacon: beacon)
                }
                
                DisclosureGroup("PAYLOAD", isExpanded: $isExpandedPayload) {
                    if let adv = beacon.adv {
                        buildViewAdv(beaconadv: adv)
                    } else {
                        Text("No data available")
                            .foregroundColor(.gray)
                    }
                }

                DisclosureGroup("LAST LOCATION", isExpanded: $isExpandedLocation) {
                    
                    if let location = beacon.location {
                        buildViewLocation(beaconlocation: location)
//                            .frame(width: 200, height: 200)
                        Text(location.address)
                    } else {
                        Text("No data available")
                            .foregroundColor(.gray)
                    }
                    if (lm.locationAuthorizationStatus == .restricted) || (lm.locationAuthorizationStatus == .denied) {
                        Button(action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }) {
                            VStack {
                                Text("Location services are currently not allowed. To store and update sensor location, allow precise location services. On your phone, please go to Settings > Thermometer and turn on Location services")
                            }
                        }
                    } else if (lm.locationAuthorizationStatus == .authorizedWhenInUse)
                                || (lm.locationAuthorizationStatus == .authorizedAlways) {
                        if (lm.locationAuthorizationAccuracy != .fullAccuracy) {
                            Button(action: {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }) {
                                VStack {
                                    Text("Location services are allowed, but currently no precise location is available. To store and update sensor location, allow precise location services. On your phone, please go to Settings > Thermometer and turn on Location services")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 40)

        }
        .navigationTitle(beacon.name!)
//        .navigationBarHidden(true)
        // https://stackoverflow.com/questions/61823392/displaying-progress-from-sessiondownloaddelegate-with-swiftui
    }
}

func getRssiString(rssi: Int16 ) -> String {
    if rssi == 127 {
        return "(n/a)"
    } else {
        return String(format:"%d dBm", rssi)
    }
}

func buildViewBeacon(beacon: Beacon) -> AnyView {
    return AnyView (
        Group {
            BeaconDetailListEntry(title: "Beacon Version",
                                  text: String(format:"%d", beacon.beacon_version))
            BeaconDetailListEntry(title: "Company ID",
                                  text: String(format:"%d", beacon.company_id))
            BeaconDetailListEntry(title: "ID Major", text: beacon.id_maj!)
            BeaconDetailListEntry(title: "ID Minor", text: beacon.id_min!)
            
            NavigationLink(destination: TextShow(fieldName: "Raw", text: beacon.uuid?.uuidString ?? "no value" )
            ) {
                BeaconDetailListEntry(title: "Raw", text: beacon.uuid?.uuidString ?? "no value" )
            }
        }
    )
}

func buildViewAdv(beaconadv: BeaconAdv) -> AnyView {
    return AnyView (
        Group {
            BeaconDetailListEntry(title: "Last data",
                                  text: getDateString(date: beaconadv.timestamp, offsetGMT: 7200))
            BeaconDetailListEntry(title: "Temperature",
                                  text: String(format:"%.2f °C", beaconadv.temperature))
            BeaconDetailListEntry(title: "Humidity",
                                  text: String(format:"%.2f %%", beaconadv.humidity))
            BeaconDetailListEntry(title: "Battery",
                                  text: String(format:"%d mV", beaconadv.battery))
            BeaconDetailListEntry(title: "Accel",
                                  text: String(format:"(%.2f g, %.2f g, %.2f g)",
                                               beaconadv.accel_x, beaconadv.accel_y, beaconadv.accel_z))
            BeaconDetailListEntry(title: "RSSI",
                                  text: getRssiString(rssi: Int16(beaconadv.rssi)))
            
            NavigationLink(destination: TextShow(fieldName: "Raw", text: beaconadv.rawdata ?? "no value" )
            ) {
                BeaconDetailListEntry(title: "Raw", text: beaconadv.rawdata ?? "no value" )
            }
        }
    )
}

func buildViewLocation(beaconlocation: BeaconLocation) -> AnyView {
    return AnyView (
        Group {
            BeaconDetailListEntry(title: "Last location",
                                  text: getDateString(date: beaconlocation.timestamp, offsetGMT: 7200))
            ZStack {
                MapView(centerCoordinate: beaconlocation.location)
                    .frame(width: 300, height: 200)   // TODO
                Circle()
                    .fill(Color.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
            }
        }
    )
}

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

