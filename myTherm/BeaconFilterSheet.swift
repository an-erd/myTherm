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
    
    var body: some View {
        NavigationView {
            List {
                BeaconFilterSheetEntry(imageName: "timer", title: "Seen recently", option: $filterByTime)
                BeaconFilterSheetEntry(imageName: "location", title: "Nearby", option: $filterByLocation)
                BeaconFilterSheetEntry(imageName: "flag.fill", color: .orange, title: "Flagged", option: $filterByFlag)
            }
            .navigationBarTitle(Text("Filter"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view... \(filterByTime) \(filterByLocation) \(filterByFlag)")
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
                    .padding(10)
//                    .border(Color.white)
            })
        }
    }
}

//struct BeaconFilterSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconFilterSheet()
//    }
//}
