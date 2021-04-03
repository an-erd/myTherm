//
//  Line.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct Line: View {
    @ObservedObject var beacon: Beacon
    @ObservedObject var localValue: BeaconLocalValueView

    var timestamp: [Date]
    var displaySteps: Int
    var dataTemperature: [Double]
    var dataHumidity: [Double]
    @Binding var frame: CGRect
    @Binding var dragMode: Bool
    @Binding var dragStart: CGFloat
    @Binding var dragOffset: CGSize
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
        let points: [Double] = (displaySteps == 0) ? self.dataTemperature : self.dataHumidity
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight), offset: offset)
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
            self.path
                .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
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
}
