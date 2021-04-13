//
//  BeaconFilterCountView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 12.04.21.
//

import Foundation
import CoreData
import SwiftUI

struct BeaconFilterCountView: View {
    
    var fetchRequest: FetchRequest<Beacon>
    init(predicate: NSPredicate?) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \Beacon.name, ascending: true)],
                                            predicate: predicate,
                                            animation: .default)
    }

    var body: some View {
        Text("\(fetchRequest.wrappedValue.count) sensors found")
            .font(.subheadline)
    }
}
