//
//  BeaconFilterSheetEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 21.03.21.
//

import SwiftUI

struct BeaconFilterSheetEntry: View {
    var imageName: String
    var color: Color?
    var title: String
    @Binding var option: Bool
    
    var body: some View {
        Button(action: {option.toggle()}) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(color)
                    .padding(.trailing, 10)
                Text(title)
                Spacer()
                if option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct BeaconFilterSheetEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconFilterSheetEntry()
//    }
//}
