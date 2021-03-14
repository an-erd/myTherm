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
    var beacon: Beacon

    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                Button(action: {
                    MyBluetoothManager.shared.downloadManager.addBeaconToDownloadQueue(beacon: beacon)
                }) {
                    Image(systemName: "icloud.and.arrow.down")
                }
                Spacer()
                    .frame(width: 25)

                Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)

            }) {
                configuration.content.padding(.top)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
