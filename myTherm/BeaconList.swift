//
//  BeaconList.swift
//  BleAdvApp
//
//  Created by Andreas Erdmann on 09.07.19.
//  Copyright © 2019 Andreas Erdmann. All rights reserved.
//

import SwiftUI

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

    var body: some View {
        
        GeometryReader { geometry in
        ScrollView {
            VStack(spacing: 8) {
                ForEach(beacons) { beacon in
                    GroupBox(label: Label(beacon.name!, systemImage: "thermometer")) {
                            HStack {
                                BeaconValueView(beacon: beacon, beaconAdv: beacon.adv!, nowDate: nowDate)
                                    .frame(width: geometry.size.width * 0.55)
                                ZStack {
                                    LineView(data: [0,1,2,3,4,5,6,7,8,9,10,0,20,0,10,0,5,0,4,0,3,0,2,0,1,0],title: "°C")
    //orange
                                    
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
    }}

        
    
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
