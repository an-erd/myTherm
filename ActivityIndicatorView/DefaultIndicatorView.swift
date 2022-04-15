//
//  DefaultIndicatorView.swift
//  ActivityIndicatorView
//
//  Created by Daniil Manin on 10/7/20.
//  Copyright © 2020 Exyte. All rights reserved.
//
//  Enhancements by Andreas Erdmann on 14.04.22
//

import SwiftUI

struct DefaultIndicatorView: View {
    
    let step: Int
    let rotate: Bool
    
    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<8) { index in
                DefaultIndicatorItemView(step: step,
                                         index: index,
                                         count: 8,
                                         rotate: rotate,
                                         size: geometry.size)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct DefaultIndicatorItemView: View {
    
    let step: Int
    let index: Int
    let count: Int
    let rotate: Bool
    let size: CGSize
    
    @State private var opacity: Double = 0
    
    func calcOpacity(step: Int, index: Int, count: Int) -> Double {
        var opac: Double
        if  index > step {
            opac = 0.0
            return 0.0
        }
        opac = Double(1.0 - Double(Double(step - index)) / Double(count))
        return opac
    }
    
    var body: some View {
        let height = size.height / 3.2
        let width = height / 2
        let angle = 2 * .pi / CGFloat(count) * CGFloat(index)
        let x = (size.width / 2 - height / 2) * cos(angle)
        let y = (size.height / 2 - height / 2) * sin(angle)
        
        let animation = Animation.default
            .repeatForever(autoreverses: true)
            .delay(Double(index) / 8.0 / 2)

        if !rotate {
            return AnyView(
                RoundedRectangle(cornerRadius: width / 2 + 1)
                    .frame(width: width, height: height)
                    .rotationEffect(Angle(radians: Double(angle + CGFloat.pi / 2)))
                    .offset(x: x, y: y)
                    .opacity(Double(calcOpacity(step: step, index: index, count: 8)))
            )
        } else {
            return AnyView(
                RoundedRectangle(cornerRadius: width / 2 + 1)
                    .frame(width: width, height: height)
                    .rotationEffect(Angle(radians: Double(angle + CGFloat.pi / 2)))
                    .offset(x: x, y: y)
//                    .opacity(index == 0 ? 1 : Double(index)/8.0)
                    .opacity(opacity)
                    .onAppear {
                        self.opacity = 0.0
                        withAnimation(animation) {
                            self.opacity = 1.0
                        }
                    }
            )
        }
    }
}

struct DefaultIndicatorViewWithControl: View {
    
    private let count: Int = 8
    @State var rotate: Bool = false
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            Slider(value: $progress, in: 0...CGFloat(count-1), step:1)
            Toggle("rotate", isOn: $rotate)
            Divider()
            VStack {
                DefaultIndicatorView(step: Int(progress), rotate: rotate)
            }
            .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct DefaultIndicatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        DefaultIndicatorViewWithControl()
    }
}
