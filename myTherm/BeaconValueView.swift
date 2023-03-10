//
//  BeaconValueView.swift
//  TestNew3
//
//  Created by Andreas Erdmann on 19.08.20.
//

import SwiftUI

struct BeaconValueView: View {
    
    var temperature: Double
    var humidity: Double
    var string: String
    
//    @ScaledMetric
    var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Text("\(temperature, specifier: "%.1f")").font(.system(size: 24 * size, weight: .bold, design: .rounded))
                    + Text(" °C").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                
                Text("\(humidity, specifier: "%.1f")").font(.system(size: 24 * size, weight: .bold, design: .rounded))
                    + Text(" %").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                Spacer()
            }
            Text(string)
                .font(.footnote).foregroundColor(.secondary)
        }
    }
}

struct BeaconValueView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconValueView(temperature: 22.3,
                        humidity: 69,
                        string: "descr")
    }
}
