//
//  Path.swift
//  myTherm
//
//  Created by Andreas Erdmann on 01.03.21.
//

import SwiftUI
import Foundation

extension Path {
    
    static func lineChart(points: [Double], step: CGPoint) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        guard let offset = points.min() else { return path }
        let p1 = CGPoint(x: 0, y: CGFloat( points[0] - offset ) * step.y)
        path.move(to: p1)
//        print("linechart * \(p1) y \(CGFloat(points[0])) offset \(offset) step.y \(step.y)")
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: step.x * CGFloat(pointIndex),
                             y: step.y * CGFloat(points[pointIndex] - offset))
            path.addLine(to: p2)
//            print("linechart   \(p2) y \(CGFloat(points[pointIndex])) offset \(offset) step.y \(step.y)")
        }
        return path
    }
}
