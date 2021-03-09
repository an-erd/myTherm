//
//  Line.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import os

struct Line: View {
    var data: [(Double)]
//    var frame: CGRect
    @Binding var frame: CGRect

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
        
        if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        } else {
            return 0
        }
        if let min = min, let max = max, min != max {
//            print("stepHeight min \(min), max \(max), diff \(max - min), height \((frame.size.height - padding) / CGFloat(max + min)) step \((frame.size.height - padding) / CGFloat(max + min))")
            if min <= 0 {
                return (frame.size.height - padding) / CGFloat(max - min)
            } else {
                return (frame.size.height - padding) / CGFloat(max + min)
            }
        }
        
        return 0
    }
    
    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    public var body: some View {
        ZStack {
            self.path
                .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
        }
//        .border(Color.white)
    }
}
