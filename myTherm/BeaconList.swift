//
//  BeaconList.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct BeaconList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
        animation: .default)
    private var beacons: FetchedResults<Beacon>

    @State private var editMode: EditMode = .inactive
    @State private var tempDisplay: Bool = true
    
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.nowDate = Date()
        }
    }

//    @State var data1: [Double] = (0..<100).map { _ in .random(in: 9.0...100.0) }
//    let blueStyle = ChartStyle(backgroundColor: .white,
//                               foregroundColor: [ColorGradient(.purple, .blue)])

    var body: some View {
        
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(beacons) { beacon in
                        GroupBox(label: Label(beacon.name!, systemImage: "thermometer")) {
                            HStack {
                                BeaconValueView(beacon: beacon, beaconAdv: beacon.adv!, nowDate: nowDate)
                                    .frame(width: geometry.size.width * 0.55)
                                
                                Button(action: { tempDisplay.toggle()}) {
                                    ZStack {
                                        tempDisplay ? LineView(data: beacon.temperatureArray, title: "°C"):
                                            LineView(data: beacon.humidityArray, title: "%")
                                    }
                                }
                            }
                        }
                        .groupBoxStyle(
                            BeaconGroupBoxStyle(color: .blue,
                                                destination: BeaconDetail(beacon: beacon, beaconadv: beacon.adv!),
                                                dateString: getDateInterpretationString(date: beacon.adv!.timestamp!, nowDate: nowDate)))
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear(perform: {
                self.onAppear()
                _ = self.timer
            })
        }
        
    }
    
    public func onAppear() {
        print("onAppear")
    }
}

struct BeaconList_Previews: PreviewProvider {
    static var previews: some View {
        BeaconList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
