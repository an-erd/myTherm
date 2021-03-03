import SwiftUI
import MapKit
import Combine

struct BeaconDetail: View {
    @ObservedObject var beacon: Beacon
    @ObservedObject var beaconadv: BeaconAdv
    
    @State private var isExpandedBeaconInfo: Bool = false
    @State private var isExpandedPayload: Bool = false
    @State private var isExpandedLastSeen: Bool = true
    @State private var isExpandedLocation: Bool = true

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: TextEdit(fieldName: "Name", name:
                                                        Binding($beacon.name)!, allowEmpty: false)
                ) {
                    BeaconDetailListEntry(title: "Name", text: beacon.name ?? "default value" )
                }

                NavigationLink(destination: TextEdit(fieldName: "Description", name:
                                                        $beacon.descrNonOptional, allowEmpty: true)
                ) {
                    BeaconDetailListEntry(title: "Description", text:
                                            beacon.descr ?? "")
                }

                DisclosureGroup("BEACON INFORMATION", isExpanded: $isExpandedBeaconInfo) {
                    BeaconDetailListEntry(title: "Device Name",
                                          text: beacon.device_name ?? "no device name")
                    buildViewBeacon(beacon: beacon)
                }
                
                DisclosureGroup("PAYLOAD", isExpanded: $isExpandedPayload) {
                    buildViewAdv(beaconadv: beaconadv)
                }

                DisclosureGroup("LAST LOCATION", isExpanded: $isExpandedLocation) {
                    if let location = beacon.location {
                        buildViewLocation(beaconlocation: location)
                    } else {
                        Text("No data available")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle(beacon.name!)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: {
                printPeripherals(uuid: beacon.uuid!)
            }) {
                Image(systemName: "icloud.and.arrow.down")
//                Image(systemName: "arrow.triangle.2.circlepath")
//                ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
            }
        }
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
                                      text: getDateString(date: beaconadv.timestamp))
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
                                      text: getDateString(date: beaconlocation.timestamp))
                ZStack {
                    MapView(centerCoordinate: beaconlocation.location)
                        .frame(width: 200, height: 200)
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
    
