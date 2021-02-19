//
//  BeaconGroupBoxStyle.swift
//  TestNew3
//
//  Created by Andreas Erdmann on 19.08.20.
//

import SwiftUI

struct BeaconGroupBoxStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V
    var dateString: String?

    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                if dateString != nil {
                    Text(dateString!).font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
                }
                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small)
            }) {
                configuration.content.padding(.top)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
