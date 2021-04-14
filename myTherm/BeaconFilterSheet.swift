//
//  BeaconFilterSheet.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 21.03.21.
//

import SwiftUI

struct BeaconFilterSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var filterByTime: Bool
    @Binding var filterByLocation: Bool
    @Binding var filterByFlag: Bool
    @Binding var filterByHidden: Bool
    @Binding var filterByShown: Bool

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Include:"),
                        footer: Text("Select one or more filter to apply simultaneously to the sensor list.")) {
                    BeaconFilterSheetEntry(imageName: "timer", title: "Seen recently", option: $filterByTime)
                    BeaconFilterSheetEntry(imageName: "location", title: "Nearby", option: $filterByLocation)
                    BeaconFilterSheetEntry(imageName: "flag.fill", color: .orange, title: "Flagged", option: $filterByFlag)
                    BeaconFilterSheetEntry(imageName: "eye.slash", color: .secondary, title: "Hidden", option: $filterByHidden)
                    BeaconFilterSheetEntry(imageName: "eye", title: "Shown", option: $filterByShown)
                }
            }
            .navigationBarTitle(Text("Filter"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view: time \(filterByTime), loc \(filterByLocation), flag \(filterByFlag), hidden \(filterByHidden), hidden \(filterByShown)")
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
                    .padding(10)
            })
        }
    }
}

struct BeaconFilterSheet_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BeaconFilterSheet(filterByTime: .constant(true), filterByLocation: .constant(false), filterByFlag: .constant(true),
                              filterByHidden: .constant(false), filterByShown: .constant(false))
            BeaconFilterSheet(filterByTime: .constant(true), filterByLocation: .constant(false), filterByFlag: .constant(true),
                              filterByHidden: .constant(false), filterByShown: .constant(false))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
