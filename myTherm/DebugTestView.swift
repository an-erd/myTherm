//
//  DebugTestView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 01.05.21.
//

import SwiftUI

struct DebugTestView: View {
    var beacons: [Beacon]
    var filter: Bool
    
    var filteredBeacons: [Beacon] {
        if filter {
            return beacons.filter { $0.flag }
        } else {
            return beacons
        }
    }
    
    var body: some View {
        VStack {
            ForEach(filteredBeacons, id: \.self) { beacon in
                Text("\(beacon.wrappedDeviceName) \(beacon.hidden ? "H" : "-") \(beacon.flag ? "F" : "-")")
            }
        }
    }
}


// DebugView1: Liste der filtered/sorted UUIDs
// DebugView2: reicht den UUID nur durch
// DebugView3: macht aus UUID den Beacon
// DebugView4: Zeigt Beacon an
struct DebugView1: View {
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

    var body: some View {
        VStack {
            DebugView2(uuidList: filteredSortedMapBeaconList)
        }
    }
}

struct DebugView2: View {
    var uuidList: [UUID]
    
    var body: some View {
        VStack {
            ForEach(uuidList, id: \.self) { uuid in
                DebugView3(uuid: uuid)
            }
        }
    }
}

struct DebugView3: View {
    var uuid: UUID
    
    @StateObject var beaconModel = BeaconModel.shared

    var beacon: Beacon? {
        return beaconModel.fetchBeacon(context: PersistenceController.shared.viewContext, with: uuid)
    }
    var body: some View {
        if let beacon = beacon {
            DebugView4(beacon: beacon)
                .equatable()
        } else {
            Text("nil")
        }
    }
}

struct DebugView4: View, Equatable {
    @ObservedObject var beacon: Beacon
    
    var body: some View {
        Text("\(beacon.wrappedDeviceName) \(beacon.hidden ? "H" : "-") \(beacon.flag ? "F" : "-") \(beacon.adv!.temperature, specifier: "%.2f")")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.beacon.hidden == rhs.beacon.hidden) && (lhs.beacon.flag == rhs.beacon.flag)
    }
}

struct DebugView5: View {
    @ObservedObject var beacon: Beacon
    @ObservedObject var localValue: BeaconLocalValueView

    var body: some View {
        Text("DebugView5")
    }
}
