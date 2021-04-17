//
//  BeaconBottomBarStatusDownloadButton.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 17.04.21.
//

import SwiftUI

struct BeaconBottomBarStatusDownloadButton: View {
    var textLine1: String
    var colorLine1: Color
    var textLine2: String
    var colorLine2: Color
    
    var body: some View {
        VStack (alignment: .center) {
            Text("\(textLine1)")
                .font(.subheadline)
                .foregroundColor(colorLine1)
            Text("\(textLine2)")
                .font(.footnote)
                .foregroundColor(colorLine2)
        }
    }
}

struct BeaconBottomBarStatusDownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        BeaconBottomBarStatusDownloadButton(textLine1: "text1", colorLine1: .primary,
                                            textLine2: "text2", colorLine2: .secondary)
    }
}
