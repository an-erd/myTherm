//
//  BeaconGroupBoxList.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI
import SwipeCell

struct BeaconGroupBoxList: View {
    @StateObject var beaconModel = BeaconModel.shared
    
    var fetchRequestWithoutFilter: FetchRequest<Beacon>
    var fetchRequestWithFilter: FetchRequest<Beacon>
    var doFilter: Bool
    
    init(doFilter: Bool, predicateWithoutFilter: NSPredicate?, predicateWithFilter: NSPredicate?) {
        fetchRequestWithoutFilter = FetchRequest<Beacon>(entity: Beacon.entity(),
                                                         sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                                         predicate: predicateWithoutFilter,
                                                         animation: .default)
        fetchRequestWithFilter = FetchRequest<Beacon>(entity: Beacon.entity(),
                                                      sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                                      predicate: predicateWithFilter,
                                                      animation: .default)
        self.doFilter = doFilter
    }
    var filteredWithoutFilterSortedMapBeaconList: [UUID] {
        fetchRequestWithoutFilter.wrappedValue.map { $0.uuid! }
    }

    var filteredWithFilterSortedMapBeaconList: [UUID] {
        fetchRequestWithFilter.wrappedValue.map { $0.uuid! }
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
            ForEach(doFilter ? filteredWithFilterSortedMapBeaconList : filteredWithoutFilterSortedMapBeaconList, id: \.self) { uuid in
                BeaconGroupBoxListUuidEntry(uuid: uuid, date: nowDate, displaySteps: displaySteps)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            _ = self.timer // hitches
        })
    }
}

