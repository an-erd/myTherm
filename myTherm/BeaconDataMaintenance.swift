//
//  BeaconDataMaintenance.swift
//  Thermometer
//
//  Created by Andreas Erdmann on 22.04.21.
//

import Foundation
import CoreData

func BeaconHistoryCleanupSpikes(context: NSManagedObjectContext) {
    
    var beacons: [Beacon] = []
    
    let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
    do {
        beacons = try context.fetch(fetchRequest)
    } catch {
        let fetchError = error as NSError
        debugPrint(fetchError)
        return
    }
    
    print("beacons fetched, num \(beacons.count)")
    
    for beacon in beacons {
        let history = beacon.historyArray
        print("\(beacon.wrappedDeviceName) count history \(history.count)")
        let historyFiltered = history.filter() { point in
            return point.temperature == -45
        }
        for point in historyFiltered {
            beacon.removeFromHistory(point)
//            print("   \(point.wrappedTimeStamp) \(point.temperature) \(point.humidity)")
        }
        print("   counter \(historyFiltered.count)")
    }
}

