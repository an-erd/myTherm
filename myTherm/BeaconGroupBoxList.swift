//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI

struct BeaconGroupBoxList: View {
    
    var fetchRequest: FetchRequest<Beacon>
    init(predicate: NSPredicate?) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                            predicate: predicate,
                                            animation: .default)
    }
    
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in     // PROFILE
            self.nowDate = Date()
        }
    }
    
    @State private var displaySteps: Int = 0    // 0 temp, 1 hum, 2 map
    
    var body: some View {
        VStack {
            ForEach(fetchRequest.wrappedValue, id: \.self) { beacon in
                BeaconGroupBoxListEntry(beacon: beacon,
                                        nowDate: nowDate,
                                        displaySteps: $displaySteps)
                .cornerRadius(10)
                .padding(10)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            _ = self.timer
        })
    }
}
