//
//  BeaconSimpleListView.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 14.03.21.
//

import SwiftUI

struct BeaconSimpleListView: View {
    var fetchRequest: FetchRequest<Beacon>

    init(filter: String) {
        fetchRequest = FetchRequest<Beacon>(entity: Beacon.entity(),
                                            sortDescriptors: [],
                                            predicate: NSPredicate(format: "device_name BEGINSWITH %@", filter))
    }

    var body: some View {
        ForEach(fetchRequest.wrappedValue, id: \.self) { beacon in
            Text("\(beacon.wrappedDeviceName)")
        }
    }
}

struct BeaconSimpleListView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext

    static var previews: some View {
        BeaconSimpleListView(filter: "FilterString")
            .environment(\.managedObjectContext, viewContext)
    }
}
