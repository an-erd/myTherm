//
//  BeaconBottomBarStatusFilterButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 21.03.21.
//

import SwiftUI

struct BeaconBottomBarStatusFilterButton: View {
    
    var filterActive: Bool
    var filterString: String
    @Binding var filterByTime: Bool
    @Binding var filterByLocation: Bool
    @Binding var filterByFlag: Bool
    
    func buildFilterString() -> String {
        var firstEntry: Bool = true
        var filterString: String = ""
        
        if filterByTime {
            filterString.append("Seen recently")
            firstEntry = false
            print("filter last seen")
        }
        if filterByLocation {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Nearby")
            print("filter nearby")
        }
        if filterByFlag {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Flagged")
            print("filter flag")
        }
        
        return filterString
    }
    
    var body: some View {
        if filterActive {
            VStack (alignment: .center) {
                Text("Filtered by:")
                    .font(.subheadline)
                Text(buildFilterString())
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(10)
        } else{
            Text(filterString)
                .font(.subheadline)
        }
    }
}

struct BeaconBottomBarStatusFilterButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            BeaconBottomBarStatusFilterButton(filterActive: true, filterString: "Filter String", filterByTime: .constant(true), filterByLocation: .constant(false), filterByFlag: .constant(true))
            BeaconBottomBarStatusFilterButton(filterActive: false, filterString: "Filter String", filterByTime: .constant(true), filterByLocation: .constant(false), filterByFlag: .constant(true))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
