//
//  TextEdit.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 12.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//
import SwiftUI

struct TextEdit : View {
    @Environment(\.managedObjectContext) private var viewContext

    var fieldName: String
    @Binding var name: String
    @State var editName: String = ""
    var allowEmpty: Bool
    
    var body: some View {
        VStack {
            List {
                ZStack {
                    HStack {
                        TextField(name, text: $editName)
                        if !editName.isEmpty {
                            Button(action: {
                                self.editName = ""
                            }) {
                                Image(systemName: "multiply.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text(fieldName), displayMode: .inline)
            .background(Color.white)
        }
        .onAppear {
            self.editName = self.name
        }
        .onDisappear {
            if self.editName == "" {
                if self.allowEmpty {
                    self.name = ""
                }
            } else {
                self.name = self.editName
            }
        }
    }
}
/*
 #if DEBUG
 struct TextEdit_Previews : PreviewProvider {
 static var previews: some View {
 TextEdit(fieldName: "Name", name: "Beac1")
 }
 }
 #endif
 */
