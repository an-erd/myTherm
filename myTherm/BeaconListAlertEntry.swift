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
        .padding(15)
    }
}

struct BeaconListAlertEntry: View {
    var title: String
    var image: String   
    var text: String
    var foregroundColor: Color
    var backgroundColor: Color
    
    var body: some View {
        
        GroupBox(
            label:
                HStack {
//                    Label(title, systemImage: image).foregroundColor(Color.white)
                    Label {
                        Text(title)
                            .fontWeight(.bold)
                            .padding(.bottom, 15)
                            .foregroundColor(foregroundColor)
                        
                    } icon: {
                        Image(systemName: image)
                            .foregroundColor(foregroundColor)

                    }
                    Spacer()
                },
            content: {
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }) {
                    VStack {
                        Text(text)
                            .foregroundColor(foregroundColor)
                    }
                }}
        )
        .groupBoxStyle(AlertGroupBox())
        .cornerRadius(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor))
        .padding(10)
    }
}

//struct BeaconListAlertEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        BeaconListAlertEntry()
//    }
//}
