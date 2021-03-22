//
//  BeaconBottomBarStatusFilterButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 21.03.21.
//

import SwiftUI

struct BeaconBottomBarStatusFilterButton: View {

    var filterActive: Bool
    @Binding var filterByTime: Bool
    @Binding var filterByLocation: Bool
    @Binding var filterByFlag: Bool
    
    func buildFilterString() -> String {
        var firstEntry: Bool = true
        var filterString: String = ""
        
        if filterByTime {
            filterString.append("Last seen")
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
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        } else{
            Text("no filter!")
        }
    }
}

