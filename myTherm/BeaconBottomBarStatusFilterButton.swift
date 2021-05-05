//
//  BeaconBottomBarStatusFilterButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 21.03.21.
//

import SwiftUI

struct BeaconBottomBarStatusFilterButton: View, Equatable {
    
    var filterActive: Bool
    @Binding var filterByTime: Bool
    @Binding var filterByLocation: Bool
    @Binding var filterByFlag: Bool
    @Binding var filterByHidden: Bool
    @Binding var filterByShown: Bool
    var predicate: NSPredicate?
    
    func buildFilterString() -> String {
        var firstEntry: Bool = true
        var filterString: String = ""
        
        if filterByTime {
            filterString.append("Recently")
            firstEntry = false
        }
        if filterByLocation {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Nearby")
        }
        if filterByFlag {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Flagged")
        }
        if filterByHidden {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Hidden")
        }
        if filterByShown {
            if !firstEntry {
                filterString.append(", ")
                firstEntry = false
            }
            filterString.append("Shown")
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
//            BeaconFilterCountView(predicate: predicate) // hitches
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.filterActive != rhs.filterActive {
            return false
        }
        
        if lhs.filterActive {
            return lhs.buildFilterString() == rhs.buildFilterString()
        } else {
            return true
        }
    }

}

struct BeaconBottomBarStatusFilterButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            BeaconBottomBarStatusFilterButton(filterActive: true, filterByTime: .constant(true), filterByLocation: .constant(false),
                                              filterByFlag: .constant(true), filterByHidden: .constant(false), filterByShown: .constant(false),
                                              predicate: nil)
            BeaconBottomBarStatusFilterButton(filterActive: false, filterByTime: .constant(true), filterByLocation: .constant(false), filterByFlag: .constant(true), filterByHidden: .constant(false), filterByShown: .constant(false),predicate: nil)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
