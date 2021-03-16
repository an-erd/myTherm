//
//  Line.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct Line: View {
    var timestamp: [Date]
    var data: [Double]
    @Binding var frame: CGRect
    @Binding var dragMode: Bool
    @Binding var dragStart: CGFloat
    @Binding var dragOffset: CGSize

    let padding:CGFloat = 0
    
    var stepWidth: CGFloat {
        if data.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.count-1)
    }
    
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data
//        var stepH: CGFloat = 0
//        var delta: CGFloat = 0
        
//        print("frame.size x \(frame) w \(frame.size.width) h \(frame.size.height) ")
        if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        } else {
            return 0
        }
        if let min = min, let max = max, min != max {
//            if min <= 0 {
            return (frame.size.height - padding) / CGFloat(max - min)
//            } else {
//                return (frame.size.height - padding) / CGFloat(max + min)
//            }
        }

        return 0
    }
    
    var offset: CGFloat {
        guard let offset = self.data.min() else { return 0 }
        return CGFloat(offset)
    }
    
    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight), offset: offset)
    }
    
    var boundX: CGFloat {
        let tempX = -frame.size.width / 2 + dragStart + dragOffset.width
        if tempX < -frame.size.width / 2 { return -frame.size.width / 2 }
        if tempX > frame.size.width / 2 { return frame.size.width / 2 }
        
        return tempX
    }
    
    var dataIndex: Int {
        return Int(round((boundX + frame.size.width / 2)/stepWidth))
    }
    
    var circleY: CGFloat {
//        print("dataIndex \(dataIndex) numentries \(data.count)")
        return CGFloat(data[dataIndex] - Double(offset)) * stepHeight - frame.size.height / 2
    }
    
    var verticalLine: Path {
        Path { path in
            path.move(to: CGPoint(x: frame.size.width / 2 + boundX, y: -20))
            path.addLine(to: CGPoint(x: frame.size.width / 2 + boundX, y: frame.size.height))
        }
    }
    
    func getDataBoxDate(dataIndex: Int) -> String {
        return getDateString(date: timestamp[dataIndex])
    }
    
    func getDataBoxValue(dataIndex: Int) -> String {
        let value: Double = data[dataIndex]
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    public var body: some View {
        ZStack {
            self.path
                .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
            if dragMode == true {
                self.verticalLine
                    .stroke(Color.white, lineWidth: 2)
                    .offset(x: 0, y: 0)
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: boundX, y: -circleY)
                Text(getDataBoxDate(dataIndex: dataIndex) + " " + getDataBoxValue(dataIndex: dataIndex))
//                    Rectangle()
                    .frame(width: 120, height: 50)
                    .background(Color.white)
//                    .clipShape(Rectangle())
                    .offset(x: boundX - 59, y: -70)
//                        .offset(x: 0, y: -60)
            }
        }
    }
}
