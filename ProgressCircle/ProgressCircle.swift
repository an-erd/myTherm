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
    case timer      // full circle decreasing vom 12am ccw

    var id: String { self.rawValue }
}

//https://stackoverflow.com/questions/61823392/displaying-progress-from-sessiondownloaddelegate-with-swiftui

struct ProgressCircle: View {
    var rotation: CGFloat = -90     // degrees, from 0 to 360, top = -90
    var progress: CGFloat = 0       // from 0 to 1.0
    var mode: ProgressCircleMode = .none
    
    struct BackgroundCircle: View {
        var body: some View {
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .opacity(0.5)
        }
    }

    struct BackgroundSquare: View {
        var body: some View {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 6, height: 6)
        }
    }
    
    struct ForegroundCircleBusy: View {
        @State private var isLoading = false
        var progress: CGFloat = 0.7
        var rotation: CGFloat = -90
        
        var body: some View {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 2)
                .rotationEffect(.degrees(Double(rotation)))
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() { self.isLoading = true}
        }
    }
    
    struct ForegroundCircleProgress: View {
        var progress: CGFloat = 0.7
        var rotation: CGFloat = -90
        
        var body: some View {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 2)
                .rotationEffect(.degrees(Double(rotation)))
        }
    }
    
    struct ForegroundCircleTimer: View {
        var progress: CGFloat = 1.0
        var rotation: CGFloat = -90
        
        var body: some View {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 2)
                .rotationEffect(.degrees(Double(rotation)))
        }
    }

    struct ForegroundCircleHandle: View {
        var progress: CGFloat = 1.0
        var rotation: CGFloat = -90

        var body: some View {
            let deg: Double = -90.0 + 360.0 * progress
            Rectangle()
                .frame(width: 5, height: 2, alignment: .leading)
                .offset(x: 8)
                .rotationEffect(Angle(degrees: deg))
        }
    }

    var body: some View {
        VStack {
            ZStack {
                switch mode {
                case .none:
                    AnyView(EmptyView())
                case .idle:
                    BackgroundCircle()
                case .busy:
                    BackgroundCircle()
                    BackgroundSquare()
                    ForegroundCircleBusy()
                case .progress:
                    BackgroundCircle()
                    BackgroundSquare()
                    ForegroundCircleProgress(progress: progress)
                case .timer:
                    BackgroundCircle()
//                    BackgroundSquare()
//                    ForegroundCircleHandle(progress: progress)
                    ForegroundCircleTimer(progress: progress)
                }
            }
            .frame(width: 20, height: 20)
        }
    }
}

struct ProgressCircleWithControl: View {
    
    @State var rotationcontrol: CGFloat = 0.0
    @State var progresscontrol: CGFloat = 0.0
    @State var selectedModecontrol: ProgressCircleMode = .none

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
            VStack {
                switch selectedModecontrol {
                case .none:
                    ProgressCircle(mode: .none)
                case .idle:
                    ProgressCircle(mode: .idle)
                case .busy:
                    ProgressCircle(mode: .busy)
                case .progress:
                    ProgressCircle(rotation: rotationcontrol, progress: progresscontrol, mode: .progress)
                case .timer:
                    ProgressCircle(rotation: rotationcontrol, progress: progresscontrol, mode: .progress)
                }
            }
            .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {

    static var previews: some View {
        ProgressCircleWithControl()
    }
}
