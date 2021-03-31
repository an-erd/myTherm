//
//  LineView.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

// see here: https://stackoverflow.com/questions/64573755/swiftui-scrollview-with-tap-and-drag-gesture
//           https://stackoverflow.com/questions/62837754/capture-touchdown-location-of-onlongpressgesture-in-swiftui

struct LineView: View {
    
    @ObservedObject var beacon: Beacon
    @ObservedObject var localValue: BeaconLocalValueView
    @Binding var isDragging: Bool
    var displaySteps: Int
    var titleStrings: [String]
    var frameSize: CGRect
    
    @GestureState var isTapping = false
    @State private var dragMode = false
    @State private var dragStart: CGFloat = 0.0
    @State private var dragOffset = CGSize.zero
    
    @State private var dragWidth: CGFloat = 0

    var startX: CGFloat = 0
    @State var longPressLocation = CGPoint.zero


    
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
        if !localValue.isDragging {
            return 0
        }
        if stepWidth == 0 {
            return 0
        }
        let idx = Int(round((boundX + dragWidth / 2) / stepWidth))
        print("dataIndex boundX \(boundX) dragWidth \(dragWidth) stepWidth \(stepWidth) index \(idx)")
//        return 0
        return idx
    }

    public var body: some View {
        
/*
    short tap
         tapGesture touch down location 47.0
         longPressGesture .onChanged
         simultaneously .onChanged
         simultaneously .onEnded
         
         TODO: Negative Values, values > width?

    short tap and move
*        tapGesture touch down location 28.0
         longPressGesture .onChanged
         simultaneously .onChanged
         ...
         simultaneously .onChanged
         simultaneously .onEnded

    long tap no move
 *       tapGesture touch down location 34.5        -> store initial location
         longPressGesture .onChanged
         simultaneously .onChanged
 *       longPressGesture .onEnded                  -> start drag
         set to zero
         simultaneously .onChanged
         dragGesture .onEnded
         sequenced .onEnded
 *       simultaneously .onEnded                    -> stop drag
         
    long tab and move
 *       tapGesture touch down location 21.5        -> store location
         longPressGesture .onChanged
         simultaneously .onChanged
 *       longPressGesture .onEnded                  -> start drag
         set to zero
         simultaneously .onChanged
         
         dragGesture .onChanged
 *       sequenced .onChanged (23.0, 6.5)           -> update values and marker
         simultaneously .onChanged
         ...
         dragGesture .onChanged
         sequenced .onChanged (29.0, 6.0)           -> --"--
         simultaneously .onChanged
         
         dragGesture .onEnded
         sequenced .onEnded
 *       simultaneously .onEnded                    -> stop drag

*/
        
        let tapGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($isTapping) {value, isTapping, transaction in
                if !isTapping {
                    print("tapGesture .updating touch down location \(value.location.x)")
                    startX  = value.location.x
                }
                isTapping = true
            }

        let longPressGesture = LongPressGesture(minimumDuration: 1)
            .onChanged { _ in
                print("longPressGesture .onChanged")
            }
            .onEnded {_ in
                print("longPressGesture .onEnded")
            }
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { _ in
                print("dragGesture .onChanged")
            }
            .onEnded {_ in
                print("dragGesture .onEnded")
            }
        
        let sequenced = longPressGesture.sequenced(before: dragGesture)
            .onChanged {value in
                switch value {
                case .second(true, let drag):
                    if let drag = drag {
                        longPressLocation = drag.location
                        print("sequenced .onChanged \(longPressLocation)")
                        startX = drag.location.x
                    } else {
                        longPressLocation = .zero
                        print("set to zero")
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                print("sequenced .onEnded")
        }

        let simultaneously = tapGesture.simultaneously(with: sequenced)
            .onChanged {_ in
                print("simultaneously .onChanged")
            }
            .onEnded {_ in
                print("simultaneously .onEnded")
            }
        
//        // Gets triggered immediately because a drag of 0 distance starts already when touching down.
//        let tapGesture = DragGesture(minimumDistance: 0)
//            .updating($isTapping) {value, isTapping, transaction in
//                if !isTapping {
//                    print("not tabbing .updating value.location.x \(value.location.x)")
////                    startX = value.location.x
//                }
//                isTapping = true
//                print("tapGesture width \(frameSize.width)")
//            }
//
//        // minimumDistance here is mainly relevant to change to red before the drag
//        let dragGesture = DragGesture(minimumDistance: 0)
//            .onChanged { dragOffset = $0.translation
//                print("dragGesture onChanged translation \($0.translation) x \($0.startLocation.x) width \(frameSize.width)")
//                dragMode = true
//                dragOffset = $0.translation
//                dragStart = $0.startLocation.x
////                dragWidth = reader.frame(in: .local).width
//                dragWidth = frameSize.width
//
//                localValue.temperature = beacon.wrappedLocalHistoryTemperature[dataIndex]
//                localValue.humidity = beacon.wrappedLocalHistoryHumidity[dataIndex]
//                localValue.timestamp = beacon.wrappedLocalHistoryTimestamp[dataIndex]
//                localValue.isDragging = true
//            }
//            .onEnded { _ in
//                print("dragGesture onEnded")
//                dragMode = false
//                localValue.isDragging = false
////
////            }
////                withAnimation {
//                    dragOffset = .zero
//                    isDragging = false
////                }
//            }
//
//        let longPressGesture = LongPressGesture(minimumDuration: 1)
//            .onEnded { value in
//                print("pressGesture LongPressGesture width \(frameSize.width) value \(value) dragStart \(startX)")
//// X2
//                dragStart = startX
//
//                withAnimation {
//                    isDragging = true
//                    dragMode = true
//                }
//            }
//
//        // The dragGesture will wait until the pressGesture has triggered after minimumDuration 1.0 seconds.
//        let combined = longPressGesture.sequenced(before: dragGesture)
//
//        // The new combined gesture is set to run together with the tapGesture.
//        let simultaneously = tapGesture.simultaneously(with: combined)
//            .onChanged { value in
//                print("simultaneously onChanged")
////                var l = value.
////                dragMode = true
//            }
//
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
                    .gesture(simultaneously)
//                    .gesture(
//                        LongPressGesture(minimumDuration: 1).sequenced(before: DragGesture()
//                            .onChanged { gesture in
//                                dragMode = true
//                                dragOffset = gesture.translation
//                                dragStart = gesture.startLocation.x
//                                dragWidth = reader.frame(in: .local).width
//
//                                localValue.temperature = beacon.wrappedLocalHistoryTemperature[dataIndex]
//                                localValue.humidity = beacon.wrappedLocalHistoryHumidity[dataIndex]
//                                localValue.timestamp = beacon.wrappedLocalHistoryTimestamp[dataIndex]
//                                localValue.isDragging = true
//                            }
//                            .onEnded { gesture in
//                                dragMode = false
//                                localValue.isDragging = false
//                            }
//                    ))
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
