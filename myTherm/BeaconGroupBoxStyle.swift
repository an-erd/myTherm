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
                    //                Image(systemName: "arrow.triangle.2.circlepath")
                    //                ProgressCircle(rotation: -90, progress: 0.7, handle: true, mode: .timer)
                }
//                Text(dateString!).font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
                Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)

            }) {
                configuration.content.padding(.top)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
