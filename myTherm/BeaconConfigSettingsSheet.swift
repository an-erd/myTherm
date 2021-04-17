//
//  BeaconConfigSettingsSheet.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 15.04.21.
//

import SwiftUI

struct BeaconConfigSettingsSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var l1: Bool = false
    @State var l2: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sensor update:"),
                        footer: Text("footer.")) {
                    BeaconFilterSheetEntry(imageName: "timer", title: "Seen recently", option: $l1)
                    BeaconFilterSheetEntry(imageName: "location", title: "Nearby", option: $l2)
                }
            }
            .navigationBarTitle(Text("Filter"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
                    .padding(10)
            })
        }
        .onDisappear {
        }

        
        
        Text("Update Sensor")
        Text("Stop Update Sensor")
        Text("Download all")
        Text("Download from recently seen")
        Text("Identify Sensor")
        Text("Maintenance View")
    }
}

struct BeaconConfigSettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        BeaconConfigSettingsSheet()
    }
}
