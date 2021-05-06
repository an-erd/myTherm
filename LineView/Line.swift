//
//  Line.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct Line: View, Equatable {
//    @ObservedObject var beacon: Beacon
    @ObservedObject var localValue: BeaconLocalValueView

    var timestamp: [Date]
    var displaySteps: Int
    var dataTemperature: [Double]
    var dataHumidity: [Double]
    @Binding var frame: CGRect
    @Binding var dragMode: Bool
    @Binding var dragStart: CGFloat
    @Binding var dragOffset: CGSize
    @Binding var isShownTemperature: Bool
    var boundX: CGFloat
    var dataIndex: Int

    let padding:CGFloat = 0
    
    var stepWidth: CGFloat {
        if dataTemperature.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(dataTemperature.count-1)
    }
    
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points: [Double] = (displaySteps == 0) ? self.dataTemperature : self.dataHumidity
        
        if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        } else {
            return 0
        }
        if let min = min, let max = max, min != max {
            return (frame.size.height - padding) / CGFloat(max - min)
        }

        return 0
    }
    
    var offset: CGFloat {
        let points: [Double] = (displaySteps == 0) ? self.dataTemperature : self.dataHumidity
        guard let offset = points.min() else { return 0 }
        return CGFloat(offset)
    }
    
    var path: Path {
//        let log = OSLog(
//            subsystem: "com.anerd.myTherm",
//            category: "chart"
//        )
//        os_signpost(.begin, log: log, name: "path", "%{public}s", beacon.wrappedDeviceName)

//        DispatchQueue.global(qos: .background).async {
//
//            DispatchQueue.main.async {
//            }
//        }

        let points: [Double] = (displaySteps == 0) ? self.dataTemperature : self.dataHumidity
        let path = Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight), offset: offset)
//        os_signpost(.end, log: log, name: "path", "%{public}s", beacon.wrappedDeviceName)
        return path
    }
    
    var circleY: CGFloat {
        let points: [Double] = (displaySteps == 0) ? self.dataTemperature : self.dataHumidity

        return CGFloat(points[dataIndex] - Double(offset)) * stepHeight - frame.size.height / 2
    }
    
    var verticalLine: Path {
        Path { path in
            path.move(to: CGPoint(x: frame.size.width / 2 + boundX, y: 0 ))
            path.addLine(to: CGPoint(x: frame.size.width / 2 + boundX, y: frame.size.height))
        }
    }
    
    public var body: some View {
        ZStack {
            HStack {
                self.path
                    .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .drawingGroup()
            }
//            .opacity(0.5)
//            HStack {
//                Spacer()
//                ProgressView()
//                Spacer()
//            }
//            .opacity(0.5)
            if dragMode == true {
                self.verticalLine
                    .stroke(Color.primary, lineWidth: 2)
                    .offset(x: 0, y: 0)
                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)
                    .offset(x: boundX, y: -circleY)
            }
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
//        return false
        
        if (lhs.frame.height != rhs.frame.height) || (lhs.frame.width != rhs.frame.width)  {
            print("line == frame size changed -> false")
            return false
        }
        
        if (lhs.displaySteps != rhs.displaySteps) {
            print("line == frame displaySteps -> false")

            return false
        }
        
        let test1 = !lhs.dragMode && !rhs.dragMode  // both in non-drag mode
        let test2 = lhs.timestamp.last == rhs.timestamp.last
        let test3 = lhs.isShownTemperature == rhs.isShownTemperature
        let test4 = lhs.isShownTemperature && (lhs.dataTemperature.last == rhs.dataTemperature.last)
        let test5 = !lhs.isShownTemperature && (lhs.dataHumidity.last == rhs.dataHumidity.last)
        let test6 = lhs.dragMode != rhs.dragMode
        let test7 = lhs.dragMode && rhs.dragMode
        let test8 = lhs.dragOffset == rhs.dragOffset
        
        // check1: non-drag, time, both showing the same, last entry correct
        if test1 {
            if test2 && test3 && ( test4 || test5) {
                return true
            }
        }
        
        // check2: diff drag/non-drag
        if test6 {
//            print("line == (\(lhs.beacon.wrappedDeviceName) \(rhs.beacon.wrappedDeviceName)) -> check2 -> false")
            return false
        }
        
        // check3: drag, offset
        if test7 && test8 {
            return true
        }
    
//        print("line == (\(lhs.beacon.wrappedDeviceName) \(rhs.beacon.wrappedDeviceName)) -> default -> false")
//        print("   drag \(lhs.dragMode ? "y" : "-") \(rhs.dragMode ? "Y" : "-") time \(lhs.timestamp.last == rhs.timestamp.last ? "= " : "!=") t/h \(lhs.isShownTemperature ? "t" : "h")\(rhs.isShownTemperature ? "t" : "h") temp \(lhs.dataTemperature.last == rhs.dataTemperature.last ? "= " : "!=") hum \(lhs.dataHumidity.last == rhs.dataHumidity.last ? "= " : "!=")")

        print("line == frame default -> false")
        return false
    }
}
