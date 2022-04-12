//
//  BeaconDetailListEntry.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 12.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//
import SwiftUI

struct BeaconDetailListEntry : View {
    var title: String
    var text: String
    
    var body: some View {
        
        HStack {
            Text(title)
            Spacer()
            Text(text)
                .lineLimit(1)
                .foregroundColor(.gray)
        }
    }
}

struct BeaconDetailListEntry_Previews : PreviewProvider {
    static var previews: some View {
        BeaconDetailListEntry(title: "Title", text: "Text")
    }
}
