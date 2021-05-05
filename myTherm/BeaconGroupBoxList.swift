//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI
import SwipeCell

struct BeaconGroupBoxList: View {
//    @EnvironmentObject var lm: LocationManager
    @StateObject var beaconModel = BeaconModel.shared
    
    var fetchRequest: FetchRequest<Beacon>
    init(predicate: NSPredicate?) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                            predicate: predicate,
                                            animation: .default)
    }
    var filteredSortedMapBeaconList: [UUID] {
        fetchRequest.wrappedValue.map { $0.uuid! }
    }
    
    @State private var displaySteps: Int = 0    // 0 temp, 1 hum
    @State var nowDate: Date = Date()

    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in     // PROFILE
            self.nowDate = Date()
        }
    }

    var body: some View {
    
        VStack {
            ForEach(filteredSortedMapBeaconList, id: \.self) { uuid in
                BeaconGroupBoxListUuidEntry(uuid: uuid, date: nowDate, displaySteps: displaySteps)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
//            _ = self.timer // hitches
        })
    }
}

