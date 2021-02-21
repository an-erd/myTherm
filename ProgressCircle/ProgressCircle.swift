//
//  ProgressCircle.swift
//  myTherm
//
//  Created by Andreas Erdmann on 20.02.21.
//

import SwiftUI

enum DownloadState: String, CaseIterable, Identifiable {
    case notstarted
    case paused
    case ongoing
    case success
    case failed
    
    var id: String { self.rawValue }
}

//https://stackoverflow.com/questions/61823392/displaying-progress-from-sessiondownloaddelegate-with-swiftui

struct ProgressCircle: View {
    @State private var progress: CGFloat = 0.0
    @State private var currentstate = "notstarted"
    
    private func viewSymbol(mystate: String) -> AnyView {
        return AnyView (
            Group {
                    if mystate == "notstarted" {
                    Image(systemName: "icloud.and.arrow.down")
                } else if mystate == "paused" {
                    Image(systemName: "pause.fill")
                } else if mystate == "ongoing" {
                    Image(systemName: "square.fill")
                        .imageScale(.small)
                } else if mystate == "success" {
                    Image(systemName: "checkmark.icloud")
                } else if mystate == "failed" {
                    Image(systemName: "exclamationmark.icloud")
                }
            } )
    }
    
    var body: some View {
        VStack(spacing: 20){
            HStack {
                Text("0%")
                Slider(value: $progress)
                Text("100%")
            }.padding()
            
            Picker("Select state:", selection: $currentstate) {
                ForEach(DownloadState.allCases) { downloadstate in
                    Text(downloadstate.rawValue.capitalized)
                }
            }
            
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 6)
                    .opacity(0.1)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, lineWidth: 6)
                    .rotationEffect(.degrees(-90))
                    .overlay(
                        viewSymbol(mystate: currentstate)
                    )
                     
            }.padding(20)
            .frame(height: 70)
            
            Spacer()
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle()
    }
}
