//
//  LineView.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct LineView: View {
    var data: [(Double)]
    var title: String?

    public init(data: [Double],
                title: String? = nil) {
        self.data = data
        self.title = title
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack(alignment: .leading, spacing: 8) {
                    Group{
                        if (self.title != nil){
                            Text(self.title!)
                                .font(.body)
                                .offset(x: -5, y: 0)
                            Spacer()
                        }
                    }.offset(x: 0, y: 0)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                
                GeometryReader{ reader in
                    Line(data: self.data,
                         frame: .constant(CGRect(x: 0, y: 0,
                                                 width: reader.frame(in: .local).width,
                                                 height: reader.frame(in: .local).height))
                    ).offset(x: 0, y: 0)
                }
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineView(data: [0,9,8,8,11,7,12],title: "Title")
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
