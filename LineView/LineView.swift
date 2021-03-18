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
    @ObservedObject var localValue: BeaconLocalValueView
    @Binding var isDrag: Bool
    var displaySteps: Int
    var titleStrings: [String]
    
    @State private var dragMode = false
    @State private var dragStart: CGFloat = 0.0
    @State private var dragOffset = CGSize.zero
    
    @State private var dragWidth: CGFloat = 0
    
    var boundX: CGFloat {
        let tempX = -dragWidth / 2 + dragStart + dragOffset.width
        if tempX < -dragWidth / 2 { return -dragWidth / 2 }
        if tempX > dragWidth / 2 { return dragWidth / 2 }
        
        return tempX
    }

    var stepWidth: CGFloat {
        if beacon.wrappedLocalHistoryTemperature.count < 2 {
            return 1
        }
        return dragWidth / CGFloat(beacon.wrappedLocalHistoryTemperature.count-1)
    }

    var dataIndex: Int {
        if !localValue.dragMode {
            return 0
        }
        return Int(round((boundX + dragWidth / 2) / stepWidth))
    }

    public var body: some View {
        GeometryReader{ geometry in
            ZStack{
                GeometryReader{ reader in
                    Line(beacon: beacon,
                         localValue: localValue,
                         timestamp: beacon.wrappedLocalHistoryTimestamp,
                         displaySteps: displaySteps,
                         dataTemperature: beacon.wrappedLocalHistoryTemperature,
                         dataHumidity: beacon.wrappedLocalHistoryHumidity,
                         frame: .constant(CGRect(x: 0, y: 0,
                                                 width: reader.frame(in: .local).width,
                                                 height: reader.frame(in: .local).height)),
                         dragMode: $dragMode, dragStart: $dragStart, dragOffset: $dragOffset,
                         boundX: boundX,
                         dataIndex: dataIndex
                    )
                    .offset(x: 0, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragMode = true
                                dragOffset = gesture.translation
                                dragStart = gesture.startLocation.x
                                dragWidth = reader.frame(in: .local).width
                                
                                localValue.temperature = beacon.wrappedLocalHistoryTemperature[dataIndex]
                                localValue.humidity = beacon.wrappedLocalHistoryHumidity[dataIndex]
                                localValue.timestamp = beacon.wrappedLocalHistoryTimestamp[dataIndex]
                                localValue.dragMode = true
                            }
                            .onEnded { gesture in
                                dragMode = false
                                localValue.dragMode = false                            }
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
