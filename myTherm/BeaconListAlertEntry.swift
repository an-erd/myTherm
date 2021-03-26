//
//  BeaconListAlertEntry.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 24.03.21.
//

import SwiftUI

struct AlertGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
//        .overlay(configuration.label.padding(.leading, 10), alignment: .topLeading)
    }
}

struct BeaconListAlertEntry: View {
    var title: String
    var image: String   
    var text: String
    
    var body: some View {
        
        GroupBox(
            label:
                HStack {
                    Label(title, systemImage: image).foregroundColor(Color.white)
                    Spacer()
                },
            content: {
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }) {
                    VStack {
                        Text(text)
                            .foregroundColor(Color.white)
                    }
                }}
        )
        .groupBoxStyle(AlertGroupBox())
        .cornerRadius(10)
        .padding(10)
    }
}

//struct BeaconListAlertEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconListAlertEntry()
//    }
//}
