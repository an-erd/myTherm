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

struct BeaconListAlertEntry: View, Equatable {
    var title: String
    var image: String   
    var text: String
    var foregroundColor: Color
    var backgroundColor: Color
    var allowDismiss: Bool
    @Binding var dismiss: Bool
    
    var body: some View {
        
        GroupBox(
            label:
                HStack {
                    Label {
                        Text(title)
                            .fontWeight(.bold)
                            .padding(.bottom, 15)
                            .foregroundColor(foregroundColor)
                        Spacer()
                        if allowDismiss {
                            Button(action: {
                                dismiss.toggle()
                            }) {
                                Image(systemName: "multiply").foregroundColor(.primary)
                                    .imageScale(.large)
                                    .padding(.trailing, 0)
                            }
                        }
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title &&
            lhs.text == rhs.text
    }

}

struct BeaconListAlertEntry_Previews: PreviewProvider {
    
    static var previews: some View {
        BeaconListAlertEntry(title: "Title",
                             image: "tortoise",
                             text: "Text",
                             foregroundColor: .white,
                             backgroundColor: Color("alertRed"),
                             allowDismiss: false,
                             dismiss: .constant(false))
    }
}
