//
//  LineView.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import Foundation
import os

// see here: https://stackoverflow.com/questions/64573755/swiftui-scrollview-with-tap-and-drag-gesture
//           https://stackoverflow.com/questions/62837754/capture-touchdown-location-of-onlongpressgesture-in-swiftui

struct LineView: View, Equatable {
    
    @StateObject var beaconModel = BeaconModel.shared

//    @ObservedObject var beacon: Beacon
    var timestamp: [Date]
    var dataTemperature: [Double]
    var dataHumidity: [Double]

    @ObservedObject var localValue: BeaconLocalValueView
    @Binding var showTemperature: Bool
    @Binding var isDragging: Bool
    var titleStrings: [String]
    var frameSize: CGRect
    
    @GestureState var isTapping = false
    @State private var dragMode = false
    @State private var dragStart: CGFloat = 0.0
    @State private var dragOffset = CGSize.zero
    @State private var dragWidth: CGFloat = 0
    
    private let log: OSLog = OSLog(subsystem: "com.anerd.myTherm", category: "Useraction")

//    @State private var isShownTemp = true
    
    var boundX: CGFloat {
        let tempX = -dragWidth / 2 + dragStart + dragOffset.width
        if tempX < -dragWidth / 2 { return -dragWidth / 2 }
        if tempX > dragWidth / 2 { return dragWidth / 2 }
        
        return tempX
    }

    var stepWidth: CGFloat {
        if dataTemperature.count < 2 {
            return 1
        }
        return dragWidth / CGFloat(dataTemperature.count-1)
    }

    var dataIndex: Int {
        if !localValue.isDragging {
//            print("dataIndex !isDragging")
            return 0
        }
        if stepWidth == 0 {
            print("dataIndex stepWidth == 0")
            return 0
        }
        let idx = Int(round((boundX + dragWidth / 2) / stepWidth))
//        print("dataIndex boundX \(boundX) dragWidth \(dragWidth) stepWidth \(stepWidth) index \(idx)")
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

         
         tapGesture .updating touch down location 64.5
         longPressGesture .onChanged
         simultaneously .onChanged
         *
*        tapGesture .onEnded
         simultaneously .onEnded
         
         tapGesture .updating touch down location 67.5
         longPressGesture .onChanged
         simultaneously .onChanged
         longPressGesture .onEnded
         set to zero
         simultaneously .onChanged
         dataIndex boundX -7.5 dragWidth 150.0 stepWidth 0.2608695652173913 index 259
*        tapGesture .onEnded
         dragGesture .onEnded
         sequenced .onEnded
         simultaneously .onEnded

*/
        
        let tapGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($isTapping) {value, isTapping, transaction in
                if !isTapping {
//                    print("tapGesture .updating touch down location \(value.location.x)")
                    localValue.firstTouchLocation = value.location.x
                }
                isTapping = true
            }
            .onEnded {_ in
//                print("tapGesture .onEnded")
                if !dragMode {
                    showTemperature.toggle()
                    os_signpost(.event, log: self.log, name: "Useraction", "tap_%{public}s", showTemperature ? "T" : "H")

//                    beaconModel.isShownTemperature.toggle()
//                    self.isShownTemp = beaconModel.isShownTemperature
                }
            }

        let longPressGesture = LongPressGesture(minimumDuration: 0.1)
            .onChanged { _ in
//                print("longPressGesture .onChanged")
            }
            .onEnded {_ in
                dragMode = true
                localValue.isDragging = true
                dragOffset = .zero
                dragStart = localValue.firstTouchLocation
                dragWidth = frameSize.width
//                print("longPressGesture .onEnded dataIndex \(dataIndex) dragOffset \(dragOffset) dragStart \(dragStart) dragWidth \(dragWidth)")

                os_signpost(.event, log: self.log, name: "Useraction", "drag_%{public}s", dragMode ? "start" : "stop")

                
                localValue.temperature = dataTemperature[dataIndex]
                localValue.humidity = dataHumidity[dataIndex]
                localValue.timestamp = timestamp[dataIndex]
                
                HapticsManager.shared?.playPull()
            }
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { _ in
//                print("dragGesture .onChanged")
            }
            .onEnded {_ in
//                print("dragGesture .onEnded")
            }
        
        
        let sequenced = longPressGesture.sequenced(before: dragGesture)
            .onChanged {value in
                switch value {
                case .second(true, let drag):
                    if let drag = drag {
//                        print("dragGesture onChanged translation \(drag.translation) x \(drag.startLocation.x) width \(frameSize.width)")
                        dragMode = true
                        dragOffset = drag.translation
                        dragStart = drag.startLocation.x
                        dragWidth = frameSize.width
                        
                        localValue.temperature = dataTemperature[dataIndex]
                        localValue.humidity = dataHumidity[dataIndex]
                        localValue.timestamp = timestamp[dataIndex]
                        localValue.isDragging = true
                    } else {
//                        print("set to zero")
                    }
                default:
                    break
                }
            }
            .onEnded { value in
//                print("sequenced .onEnded")
        }

        let simultaneously = tapGesture.simultaneously(with: sequenced)
            .onChanged {_ in
//                print("simultaneously .onChanged")
            }
            .onEnded {_ in
//                print("simultaneously .onEnded")
                dragMode = false
                localValue.isDragging = false
                dragOffset = .zero
                isDragging = false
            }
        
        GeometryReader{ geometry in
            ZStack{
                GeometryReader{ reader in
                    Line(localValue: localValue,
                         timestamp: timestamp,
                         displaySteps: beaconModel.isShownTemperature ? 0 : 1,
                         dataTemperature: dataTemperature,
                         dataHumidity: dataHumidity,
                         frame: .constant(CGRect(x: 0, y: 0,
                                                 width: reader.frame(in: .local).width,
                                                 height: reader.frame(in: .local).height)),
                         dragMode: $dragMode, dragStart: $dragStart, dragOffset: $dragOffset,
                         isShownTemperature: $beaconModel.isShownTemperature,
                         boundX: boundX,
                         dataIndex: dataIndex
                    )
                    .equatable()
                    .offset(x: 0, y: 0)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Text(self.titleStrings[beaconModel.isShownTemperature ? 0 : 1])
                            .font(.body)
                            .foregroundColor(Color.primary)
                            .offset(x: -5, y: 0)
                    }
                    Spacer()

                }.offset(x: 0, y: 0)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .contentShape(Rectangle())
            .gesture(simultaneously)

        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
//        return false
        
        if (lhs.frameSize.height != rhs.frameSize.height) || (lhs.frameSize.width != rhs.frameSize.width)  {
//            print("LineView frame size changed -> false")
            return false
        }

        let test1 = lhs.dragMode && rhs.dragMode
        let test2 = lhs.dragMode != rhs.dragMode
        let test3 = !lhs.dragMode && !rhs.dragMode
        let test4 = lhs.showTemperature == rhs.showTemperature
        let test5 = lhs.timestamp.last == rhs.timestamp.last
        let test6 = lhs.dataTemperature.last == rhs.dataTemperature.last
        
        // check1
        if test1 || test2 || (test3 && !test4) {
//            print("LineView check1 -> false")
            return false
        }
        
        // check2
        if test3 {
           let test = test4 && test5 && test6
            if !test {
//                print("LineView check2 -> false")
                return false
            } else {
                return true
            }
        }
        print("LineView default -> false")

        return false
    }
}

struct LineView_wrapper: View {
    @State private var localValue2 = BeaconLocalValueView()

    var body: some View {
        Group {
            LineView(timestamp: [ Date(),
                                  Date().addingTimeInterval(1),
                                  Date().addingTimeInterval(2),
                                  Date().addingTimeInterval(3),
                                  Date().addingTimeInterval(4),
                                  Date().addingTimeInterval(5),
                                  Date().addingTimeInterval(6),
                                  Date().addingTimeInterval(7),
                                  Date().addingTimeInterval(8),
                                  Date().addingTimeInterval(9)],
                     dataTemperature: [ 1, 0.623,0.696,0.798,0.798,0.623,0.501,0.571,0.713,0.851],
                     dataHumidity: [ 1, 0.623,0.696,0.798,0.798,0.623,0.501,0.571,0.713,0.851],
                     localValue: localValue2,
                     showTemperature: .constant(false),
                     isDragging: .constant(false),
                     titleStrings: [ "C", "H"],
            frameSize: CGRect(x: 20, y: 20, width: 20, height: 20))
//            LineView(data: [0.6239593970127428,0.6965895913740223,0.7989321379739961,0.7989321379739961,0.6239593970127428,0.5018086155869746,0.5711374374772689,0.7130964537288593,0.8517540975094645], title: "title")
//            LineView(data: [0,9,8,8,11,7,12],title: "Title")
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView_wrapper()
    }
}
