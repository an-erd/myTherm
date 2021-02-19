//
//  TextShow.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 19.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//
import SwiftUI

struct TextShow : View {
    var fieldName: String
    var text: String
    
    var body: some View {
        VStack {
            List {
                Text(text)
                .lineLimit(nil)
            }
            .navigationBarTitle(Text(fieldName), displayMode: .inline)
                .background(Color.white)
        }
    }
}
/*
#if DEBUG
struct TextShow_Previews : PreviewProvider {
    static var previews: some View {
        TextEdit(fieldName: "Name", name: "Beac1")
    }
}
#endif
*/
