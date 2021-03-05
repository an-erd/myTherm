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
    private var min: Double?
    private var max: Double?
    private var width: Double?
    private var heigth: Double?

    public init(data: [Double],
                title: String? = nil) {
        self.data = data
        self.title = title
        min = data.min()
        max = data.max()
//        print("LineView count \(data.count) min \(min ?? 0) max \(max ?? 0)")
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            ZStack{
                GeometryReader{ reader in
                    Line(data: self.data,
                         frame: .constant(CGRect(x: 0, y: 0,
                                                 width: reader.frame(in: .local).width,
                                                 height: reader.frame(in: .local).height))
                    ).offset(x: 0, y: 0)
                }
                
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
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            LineView(data: [ 1, 0.623,0.696,0.798,0.798,0.623,0.501,0.571,0.713,0.851], title: "title")
//            LineView(data: [0.6239593970127428,0.6965895913740223,0.7989321379739961,0.7989321379739961,0.6239593970127428,0.5018086155869746,0.5711374374772689,0.7130964537288593,0.8517540975094645], title: "title")
//            LineView(data: [0,9,8,8,11,7,12],title: "Title")
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
