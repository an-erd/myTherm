//
//  ProgressCircle.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
//

import SwiftUI

enum ProgressCircleMode: String, CaseIterable, Identifiable {
    case none       // nothing, for e.g. for only a symbol
    case idle       // gray circle
    case busy       // fixed len (= progress) circle section rotating (= rotation)
    case progress   // circle section starting filling to value
    case timer      // circle section reducing with dot handle (timer)
    
    var id: String { self.rawValue }
}

//https://stackoverflow.com/questions/61823392/displaying-progress-from-sessiondownloaddelegate-with-swiftui

struct ProgressCircle: View {
     var rotation: CGFloat            // degrees, from 0 to 360, top = -90
     var progress: CGFloat            // from 0 to 1.0
     var handle: Bool                 // use a dot as handle
     var mode: ProgressCircleMode
    
    struct BackgroundCircle: View {
        var body: some View {
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .opacity(0.5)
        }
    }
    
    struct ForegroundCircle: View {
        var progress: CGFloat
        var rotation: CGFloat
        @State private var isLoading = false
        var body: some View {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 2)
//                .rotationEffect(.degrees(Double(rotation)))
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() { isLoading = true}
        }
    }
    
    struct RotatingHand: View {
        var rotation: CGFloat
        
        var body: some View {
            Rectangle()
                .offset(x: 6)
                .frame(width: 8, height: 2)
                .foregroundColor(.blue)
                .rotationEffect(.degrees(Double(rotation)))
        }
    }

    var body: some View {
        VStack {
            ZStack {
                if mode != .none {
                    BackgroundCircle()
                    if mode != .idle {
                        ForegroundCircle(progress: progress, rotation:  rotation)
                        if handle {
                            RotatingHand(rotation: rotation + 360 * progress)
                        }
                    }
                }
            }
            .frame(width: 20, height: 20)
        }
    }
}

struct ProgressCircleIdle: View {
    var body: some View {
        ProgressCircle(rotation: 0, progress: 0, handle: false, mode: .idle)
    }
}

//struct ProgressCircleBusy: View {
//    var body: some View {
////        Progre
//    }
//}

struct ProgressCircleWithControl: View {
    
    @State  var rotationcontrol: CGFloat  = 0.0
    @State  var progresscontrol: CGFloat  = 0.0
    @State  var selectedModecontrol: ProgressCircleMode = .none

    var body: some View {
        VStack {
            Slider(value: $rotationcontrol, in: 0...360, step:10)
            Slider(value: $progresscontrol, in: 0...1.0, step:0.05)
            Picker("Mode", selection: $selectedModecontrol) {
                ForEach(ProgressCircleMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                }
            }
            Divider()
            ProgressCircle(rotation: rotationcontrol,
                           progress: progresscontrol,
                           handle: selectedModecontrol == .timer,
                           mode: selectedModecontrol
            )
            .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {

    static var previews: some View {
        ProgressCircleWithControl()
    }
}
