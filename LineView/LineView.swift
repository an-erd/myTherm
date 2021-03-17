//
//  LineView.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct LineView: View {
    
    @ObservedObject var beacon: Beacon
    var displaySteps: Int
    var titleStrings: [String]
    
    private var timestamp: [Date]
    private var dataTemperature: [Double]
    private var dataHumidity: [Double]
            
    @State private var dragMode = false
    @State private var dragStart: CGFloat = 0.0
    @State private var dragOffset = CGSize.zero
    
    public init(beacon: Beacon, displaySteps: Int, titleStrings: [String]) {
        self.beacon = beacon
        self.timestamp = beacon.wrappedLocalHistoryTimestamp
        self.dataTemperature = beacon.wrappedLocalHistoryTemperature
        self.dataHumidity = beacon.wrappedLocalHistoryHumidity
        self.displaySteps = displaySteps
        self.titleStrings = titleStrings
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            ZStack{
                GeometryReader{ reader in
                    Line(beacon: beacon,
                         timestamp: self.timestamp,
                         displaySteps: displaySteps,
                         dataTemperature: self.dataTemperature,
                         dataHumidity: self.dataHumidity,
                         frame: .constant(CGRect(x: 0, y: 0,
                                                 width: reader.frame(in: .local).width,
                                                 height: reader.frame(in: .local).height)),
                         dragMode: $dragMode, dragStart: $dragStart, dragOffset: $dragOffset
                    )
                    .offset(x: 0, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragMode = true
                                dragOffset = gesture.translation
                                dragStart = gesture.startLocation.x
                                beacon.localDragMode = true
                            }
                            .onEnded { gesture in
                                dragMode = false
                                beacon.localDragMode = false
                            }
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Text(self.titleStrings[displaySteps])
                            .font(.body)
                            .foregroundColor(Color.white)
                            .offset(x: -5, y: 0)
                    }
                    Spacer()

                }.offset(x: 0, y: 0)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
}

//struct LineView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            LineView(timestamp: [ Date(),
//                                  Date().addingTimeInterval(1),
//                                  Date().addingTimeInterval(2),
//                                  Date().addingTimeInterval(3),
//                                  Date().addingTimeInterval(4),
//                                  Date().addingTimeInterval(5),
//                                  Date().addingTimeInterval(6),
//                                  Date().addingTimeInterval(7),
//                                  Date().addingTimeInterval(8),
//                                  Date().addingTimeInterval(9)],
//                data: [ 1, 0.623,0.696,0.798,0.798,0.623,0.501,0.571,0.713,0.851], title: "title")
////            LineView(data: [0.6239593970127428,0.6965895913740223,0.7989321379739961,0.7989321379739961,0.6239593970127428,0.5018086155869746,0.5711374374772689,0.7130964537288593,0.8517540975094645], title: "title")
////            LineView(data: [0,9,8,8,11,7,12],title: "Title")
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//    }
//}
